require 'optparse'
require 'fileutils'
require_relative 'action'
require_relative 'env'

class GenKeyAction < Action

  def set_options()
    super
    @options = {}
    @opts = OptionParser.new do |opts|

      opts.banner = 'Usage: vsense genkey <environment name>'

      opts.on('-f','--force','Overwrite existing key') do |f|
        @options[:force] = f
      end

      opts.on_tail("-h", "--help", "Show this message") do
        STDERR.puts opts
        exit
      end

    end
  end

  def validate()
    super    
    env = Environment.info(@args[0])
    if !env[0]
      STDERR.puts "Unknown environment #{@args[0]}".red
      exit 1
    elsif env[0]['type'] != 'build'
      STDERR.puts 'Can only generate PGP keys for build environemnt.'.red
      STDERR.puts "(#{@args[0]} is a #{env[0]['type']} environment)".red
      exit 1
    end      
  end

  def run()
    super

    pub_file = File.join(@env_dir,'bigsense.pub')
    sec_file = File.join(@env_dir,'bigsense.sec')

    if File.exists?(pub_file) or File.exists?(sec_file)
      if @options[:force] 
        puts 'Warning: overwriting existing key(s)'.gray
      else
        STDERR.puts 'Keys already exist. Aborting. (Use -f to force)'.red
        exit 2
      end
    end

    puts "Creating PGP Keys for #{@args[0]}".green
    pgp = settings()['pgp']

pgpfile = <<-PGPBATCH
Key-Type: #{pgp['key_type']}
Key-Length: #{pgp['key_length']}
Subkey-Type: #{pgp['subkey_type']}
Subkey-Length: #{pgp['subkey_length']}
Name-Real: #{pgp['name']}
Name-Comment: #{pgp['comment']}
Expire-Date: #{pgp['expire']}
Passphrase: #{pgp['passphrase']}
%pubring #{pub_file}
%secring #{sec_file}
%commit
%echo done
PGPBATCH

   puts pgpfile.brown
   puts 'Note: This may take a long time'.gray

   batch_file = File.join(@env_dir,'pgp.batch')
   fd = File.write(batch_file,pgpfile)
   system('gpg','--gen-key','--batch',batch_file)
   File.delete(batch_file)


  end

end