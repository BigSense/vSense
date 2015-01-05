require 'optparse'
require 'fileutils'
require_relative 'action'
require_relative 'env'

class CreateAction < Action

  DATABASES = [:mysql,:postgres,:mssql]

## Arguments

  def set_options()
    super
    @options = {}
    @opts = OptionParser.new do |opts|

      opts.banner = 'Usage: vsense create [-f] [-e (build|run)] [-b <build environment name>] [-d (mysql|postgres|mssql)] <environment name>'

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

      opts.on('-d','--database DATABASE',DATABASES,'Database backend (mysql|postgres|mssql)') do |db|
        @options[:database] = db
      end

      opts.on('-b','--build BUILD','Use a local build environment [default: use official bigsense.io]') do |build|
        @options[:build] = build
      end

    end
  end

  def validate()
    super

    #set defaults
    if @options[:environment].nil?
      @options[:environment] = :run
    end

    #build validation rules
    if @options[:environment] == :build
      if not @options[:build].nil?
        STDERR.puts "Build environments do not take a -b/--build flag"
        exit 1
      end
      if not @options[:database].nil?
        STDERR.puts "Build environments do not take -d/--database flag"
        exit 1
      end
    end

    #runtime validation rules
    if @options[:environment] == :run
      if not @options[:build].nil? and not Environment.build_envs().include?(@options[:build])
        STDERR.puts "#{@options[:build]} is not a valid build environment".red
        exit 1
      end
      if @options[:database].nil?
        STDERR.puts "-d database type required.".red
        exit 1
      end
      if not DATABASES.include?(@options[:database])
        STDERR.puts "#{@options[:database]} is not a valid database type".red
        exit 1
      end
    end



  end

  def run()
    super

    if File.exists?(@env_dir)
      STDOUT.puts ('Environment already exists: %s' %[@env_dir]).red
      exit 2
    end

    FileUtils.mkdir_p @env_dir

    ## Build Env

    if @options[:environment] == :build

      puts ('Creating Build Environment: %s' % @args[0]).green
      FileUtils.cp_r( File.join(BASE,'core/build/environment.yml'), @env_dir)

    else # default is :run

      puts ('Creating Runtime Environment: %s' % @args[0]).green

      # configuration

      env_config = YAML.load_file(File.join(BASE,'core/run/environment.yml'))

      for i in env_config['servers'].keys
        env_config['servers'][i]['hostname'].sub!('%env%',@args[0])
      end

      # connected to a build environment?

      if not @options[:build].nil?
        build_config = YAML.load_file(File.join(ENVS,@options[:build],"environment.yml"))
        env_config['repository']['host'] = '%s.%s' % [build_config['servers']['repository']['hostname'], build_config['domain']]
        env_config['repository']['custom'] = true
        env_config['repository']['ip'] = build_config['servers']['repository']['ip']
        env_config['repository']['ip_regex'] = '^' + build_config['servers']['repository']['ip'].gsub('.','\.')
        env_config['repository']['protocol'] = 'http'
      end

      env_config['database'] = @options[:database]

      # files

      File.open(File.join(@env_dir,'environment.yml'), 'w') do |file|
        file.write(env_config.to_yaml)
      end

    end

    #shared

    env_str = @options[:environment].to_s
    File.symlink(File.join(BASE,"core/#{env_str}/Vagrantfile"),File.join(@env_dir,'Vagrantfile'))
    File.symlink(File.join(BASE,'core/vagrantenv.rb'),File.join(@env_dir,'vagrantenv.rb'))
    File.symlink(File.join(BASE,'ansible'),File.join(@env_dir,'ansible'))

    Environment::add(@args[0],env_str)

    step = 0
    puts ('%d) Review the default settings in %s' %[step+=1,File.join(@env_dir,'environment.yml')]).cyan
    if @options[:environment] == :build
      puts ("#{step+=1}) Run the following to generate your PGP keys:").cyan
      puts ("\t./vsense genkeys %s" %[@args[0]]).cyan
      puts ("\t(alternatively, export your PGP key to #{@env_dir}/bigsense.pub and bigsnese.sec").cyan
    end
    puts ('%d) Run ./vsense start %s' %[step+=1,@args[0]]).cyan

  end

end