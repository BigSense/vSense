require 'optparse'
require 'fileutils'
require_relative 'action'
require_relative 'env'

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
  end

  def run()
    super

    ## Build Env

    if @options[:environment] == :build

      if File.exists?(@env_dir)
        STDOUT.puts ('Environment already exists: %s' %[@env_dir]).red
        exit 2
      else
        puts ('Creating Build Environment: %s' % @args[0]).green
        FileUtils.mkdir_p @env_dir
        FileUtils.cp_r( File.join(BASE,'core/build/environment.yml'), @env_dir)
        File.symlink(File.join(BASE,'core/build/Vagrantfile'),File.join(@env_dir,'Vagrantfile'))
        File.symlink(File.join(BASE,'core/vagrantenv.rb'),File.join(@env_dir,'vagrantenv.rb'))
        File.symlink(File.join(BASE,'ansible'),File.join(@env_dir,'ansible'))
        Environment::add(@args[0],:build.to_s)

        puts ('1) Review the default settings in %s' %[File.join(@env_dir,'environment.yml')]).cyan
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