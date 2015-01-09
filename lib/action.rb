require 'optparse'
require 'pathname'

class Action

  BASE    = Pathname.new(File.join(File.dirname(File.expand_path __FILE__),'..')).realpath
  ENVS    = File.join(BASE,'virtual-env')

  @args = nil
  @opts = nil
  @env_dir  = nil
  @command = nil

  def initialize(args)
    @command = args[0]
    @args = args.drop(1)
    @env_dir  = (@args.length > 0) ? File.join(ENVS,@args.last) : nil
    set_options
    validate
  end

  def set_options()
  end

  def settings()
    YAML.load_file(File.join(ENVS,@args[0],'environment.yml'))
  end

  def validate()
    if @opts.nil?
      STDERR.puts "Option Parser for Action is Unimplemented"
      exit 4
    end
    begin @opts.parse! @args
    rescue *[OptionParser::InvalidOption,OptionParser::InvalidArgument] => e
      STDERR.puts e
      STDERR.puts @opts
      exit 1
    end

    #Every action requires an environment name to act on
    # if this changes, we can add an option boolean parameter
    if @args.length == 0
      STDERR.puts @opts
      exit 1
    elsif @args.length != 1
      STDERR.puts ('Unknown trailing arguments: %s' %[@args.drop(1)]).red
      exit 1
    end
  end

  def run()
  end

end