require 'optparse'

class Action

  @args = nil
  @opts = nil

  def initialize(args)
  	@args = args.drop(1)
  	set_options()
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