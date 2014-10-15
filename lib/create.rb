require 'optparse'
require 'fileutils'
require_relative 'action'

class CreateAction < Action

## Arguments

  def set_options()
    super
    @options = {}
    @opts = OptionParser.new do |opts|

      opts.banner = 'Usage: vsense create [-f] [-e (build|run)] [-d (mysql|postgres|mssql)] <environment name>'

      opts.on_tail("-h", "--help", "Show this message") do
        STDERR.puts opts
        exit
      end

      opts.on('-f','--fixtures','Install fixtures') do |f|
        @options[:fixtures] = f
      end

      opts.on('-e','--env ENVIRONMENT',[:build,:run],'Environment type (build|run) [default: run]') do |e|
        @options[:environment] = e
      end

      opts.on('-d','--database DATABASE',[:mysql,:postgres,:mssql],'Database backend (mysql|postgres|mssql)') do |db|
        @options[:database] = db
      end

    end
  end

  def validate()
    super    
    if @args.length == 0
      STDERR.puts 'You must specify an environment name'.red
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

        puts ('1) Review the default settings in %s' %[File.join(env_dir,'environment.yml')]).magenta
        puts ('2) Run the following to generate your PGP keys:').magenta
        puts ('\t./vsense genkeys %s' %[@args[0]]).magenta
        puts ('\t(alternatively, export your PGP key to (insert path)').magenta
        puts ('3) Run ./vsense start %s' %[@args[0]]).magenta
        #puts 'Then run vagrant up repo'
      end

    elsif @options[:environmnet] == :run
      puts('TODO: implement').red
    else
      STDERR.puts ('Unknown environment type %s' %[@options[:environment]]).red
      exit 3
    end
  end

end