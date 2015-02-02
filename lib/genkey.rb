require 'optparse'
require 'fileutils'
require_relative 'action'
require_relative 'env'

class GenKeyAction < Action

  @pub_file = nil
  @sec_file = nil

  @key_file = nil
  @pem_file = nil

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

    @pub_file = File.join(@env_dir,'bigsense.pub')
    @sec_file = File.join(@env_dir,'bigsense.sec')

    @key_file = File.join(@env_dir,'bigsense-ssl.key')
    @pem_file = File.join(@env_dir,'bigsense-ssl.pem')

    env = Environment.info(@args[0])
    if !env[0]
      STDERR.puts "Unknown environment #{@args[0]}".red
      exit 1
    elsif env[0]['type'] != 'build' and env[0]['type'] != 'infrastructure'
      STDERR.puts 'Can only generate PGP/SSL keys for build or infrastructure environemnts.'.red
      STDERR.puts "(#{@args[0]} is a #{env[0]['type']} environment)".red
      exit 1
    end


    if (env[0]['type'] == 'build' and (File.exists?(@pub_file) or File.exists?(@sec_file))) or
       (env[0]['type'] == 'infrastructure' and (File.exists?(@key_file) or File.exists?(@pem_file)))
      if @options[:force]
        puts 'Warning: overwriting existing key(s)'.gray
      else
        STDERR.puts 'Keys already exist. Aborting. (Use -f to force)'.red
        exit 2
      end
    end

  end

  def run()
    super

    case Environment.info(@args[0])[0]['type']
      when 'build'

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
%pubring #{@pub_file}
%secring #{@sec_file}
%commit
%echo done
PGPBATCH

       puts pgpfile.brown
       puts 'Note: This may take a long time'.gray

       batch_file = File.join(@env_dir,'pgp.batch')
       fd = File.write(batch_file,pgpfile)
       system('gpg','--gen-key','--batch',batch_file)
       File.delete(batch_file)

      when 'infrastructure'
        puts "Creating Self-Signed SSL Keys for #{@args[0]}".green
        system('openssl', 'req', '-x509', '-nodes', '-days', '3650', '-newkey',
        'rsa:2048', '-keyout', @key_file, '-out', @pem_file)
    end


  end

end