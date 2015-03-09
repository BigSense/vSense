require 'optparse'
require 'fileutils'
require_relative 'action'
require_relative 'env'

class CreateAction < Action

  DATABASES = [:mysql,:postgres,:mssql]

  RUN_OS = [:ubuntu, :debian, :centos, :opensuse]

  STAGES = [:stable, :testing, :nightly]

  FIXTURES = [:gls]

## Arguments

  def set_options()
    super
    @options = {}
    @opts = OptionParser.new do |opts|

      opts.banner = 'Usage: vsense create [-f <fixture>] [-e <env_type>] [-b <build_env>] [-d <db>] [-o <os>] [-s <stage>] <environment name>'

      opts.on_tail("-h", "--help", "Show this message") do
        STDERR.puts opts
        exit
      end

      opts.on('-f','--fixtures','Install fixtures (gls)') do |f|
        @options[:fixtures] = f
      end

      opts.on('-e','--env ENVIRONMENT',[:build,:run,:infrastructure],'Environment type (build|run|infrastructure) [default: run]') do |e|
        @options[:environment] = e
      end

      opts.on('-d','--database DATABASE',DATABASES,'Database backend (mysql|postgres|mssql)') do |db|
        @options[:database] = db
      end

      opts.on('-o','--os RUN_OS', RUN_OS,'Runtime OS/distribution (ubuntu|debian|centos|opensuse) [default: ubuntu]') do |os|
        @options[:os] = os
      end

      opts.on('-s','--stage STAGE',STAGES,'Stage (nightly|testing|stable) [default: stable]') do |stage|
        @options[:stage] = stage
      end

      opts.on('-b','--build BUILD','Use a local build environment [default: use official bigsense.io]') do |build|
        @options[:build] = build
      end

    end
  end

  def validate()
    super

    #set global defaults

    if @options[:environment].nil?
      @options[:environment] = :run
    end

    # flags not used on build or infrastructure environments

    if @options[:environment] == :build or @options[:environment] == :infrastructure
      @options.each do |key,val|
        if not ([key[0]] & ['b','d','s','o', 'f']).empty?
          STDERR.puts "Only run environment take a --#{key} flag".red
          exit 1
        end
      end
    end

    # valid fixture set
    if not @options[:fixtures].nil? and not FIXTURES.include?(@options[:fixtures])
      STDERR.puts "#{@options[:fixtures]} is not a valid fixture.".red
      exit 1
    end

    # Run defaults

    if @options[:stage].nil?
      @options[:stage] = 'stable'
    end
    if @options[:os].nil?
      @options[:os] = 'ubuntu'
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
    env_config = YAML.load_file(File.join(BASE,"core/#{@options[:environment]}/environment.yml"))
    env_config['name'] = @args[0]

    ## Build Env

    if @options[:environment] == :build or @options[:environment] == :infrastructure

      puts ("Creating #{@options[:environment]} environment: #{@args[0]}").green


    else # default is :run

      puts ('Creating Runtime Environment: %s' % @args[0]).green

      # configuration

      for i in env_config['servers'].keys
        env_config['servers'][i]['hostname'].sub!('%env%',@args[0])
      end

      if not @options[:fixtures].nil?
        env_config['fixtures'] = @options[:fixtures].to_s
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

      env_config['database']['type'] = @options[:database].to_s
      env_config['servers']['bigsense']['os'] = @options[:os].to_s
      env_config['servers']['ltsense']['os'] = @options[:os].to_s
      env_config['repository']['stage'] = @options[:stage].to_s

    end

    #shared

    File.open(File.join(@env_dir,'environment.yml'), 'w') do |file|
      file.write(env_config.to_yaml)
    end

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
    if @options[:environment] == :infrastructure
      puts ("#{step+=1}) Run the following to generate self-signed SSL keys:").cyan
      puts ("\t./vsense genkeys %s" %[@args[0]]).cyan
      puts ("\t(alternatively, export your SSL keys to #{@env_dir}/bigsense-ssl.key and bigsnese-ssl.crt").cyan
    end
    puts ('%d) Run ./vsense start %s' %[step+=1,@args[0]]).cyan

  end

end