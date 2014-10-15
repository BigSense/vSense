require 'optparse'
require 'fileutils'
require_relative 'action'

class GenKeyAction < Action

## Arguments


pgpfile = <<-PGPBATCH
Key-Type: #{pgp.key_type}
Key-Length: #{pgp.key_length}
Subkey-Type: #{pgp.subkey_type}
Subkey-Length: #{pgp.subkey_length}
Name-Real: #{pgp.name}
Name-Comment: #{pgp.comment}
Expire-Date: #{pgp.expire}
Passphrase: #{pgp.passphrase}
%pubring bigsense.pub
%secring bigsense.sec
%commit
%echo done
PGPBATCH

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
    if @args.length == 0
      STDERR.puts @opts
      exit 1
    elsif @args.length != 1
      STDERR.puts ('Unknown trailing arguments: %s' %[@args.drop(1)]).red
      exit 1
    end    
  end

  def run()
    super
    #TODO expand full path
    base    = File.join(File.dirname(File.expand_path __FILE__),'..')
    env_dir = File.join(base,'virtual-env',@args[0])

    

    ## Build Env

    if @options[:environment] == :build

      if File.exists?(env_dir)
        STDOUT.puts ('Environment already exists: %s' %[env_dir]).red
        exit 2
      else
        puts ('Creating Build Environment: %s' % @args[0]).green
        FileUtils.mkdir_p env_dir
        FileUtils.cp_r( File.join(base,'core/build/environment.yml'), env_dir)
        File.symlink(File.join(base,'core/build/Vagrantfile'),File.join(env_dir,'Vagrantfile'))
        File.symlink(File.join(base,'core/vagrantenv.rb'),File.join(env_dir,'vagrantenv.rb'))
        File.symlink(File.join(base,'ansible'),File.join(env_dir,'ansible'))

        puts ('1) Review the default settings in %s' %[File.join(env_dir,'environment.yml')]).cyan
        puts ('2) Run the following to generate your PGP keys:').cyan
        puts ("\t./vsense genkeys %s" %[@args[0]]).cyan
        puts ("\t(alternatively, export your PGP key to (insert path)").cyan
        puts ('3) Run ./vsense start %s' %[@args[0]]).cyan
      end

    else #default is :run
      puts ('TODO: implement').red
    end
  end

end