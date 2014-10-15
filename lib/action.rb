require 'optparse'

class Action


  #TODO expand full path
  BASE    = File.join(File.dirname(File.expand_path __FILE__),'..')
  ENVS    = File.join(BASE,'virtual-env')

  @args = nil
  @opts = nil
  @env_dir  = nil

  def initialize(args)
  	@args = args.drop(1)
    set_options
    validate
    @env_dir  = File.join(ENVS,@args[0])
  end

  def set_options()
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
  end

  def run()
  end

end