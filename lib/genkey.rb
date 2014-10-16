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
    puts 'Creating PGP Keys for #{@args[0]}'.green
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
%pubring bigsense.pub
%secring bigsense.sec
%commit
%echo done
PGPBATCH

#gpg --gen-key --batch {{ repoman_home }}/pgp.batch

    puts pgpfile.brown


  end

end