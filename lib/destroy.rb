require 'optparse'
require 'fileutils'
require_relative 'action'
require_relative 'env'

class DestroyAction < Action

## Arguments

  def set_options()
    super
    @options = {}
    @opts = OptionParser.new do |opts|

      opts.banner = 'Usage: vsense destroy [-f] <environment name>'

      opts.on_tail("-h", "--help", "Show this message") do
        STDERR.puts opts
        exit
      end

      opts.on('-f','--force','Required to remove environment') do |f|
        @options[:force] = f
      end

    end
  end

  def validate()
    super     
    if !@options[:force]
      STDERR.puts '-f required to delete an environment'.red
      exit 1
    end
  end

  def run()
    super

    # TODO: shutdown env if running
    if !File.exists?(@env_dir)
      STDERR.puts "Environment #{@args[0]} not found".red
      exit 1
    end

    FileUtils.rm_rf(@env_dir)
    Environment::del(@args[0])

  end

end