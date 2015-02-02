require_relative 'action'

class Vagrant < Action

  def self.run_cmd(env_path, vargs)
    Dir.chdir(env_path) do
      system("vagrant " + vargs)
    end
  end

  def set_options()
    @opts = OptionParser.new do |opts|
      opts.banner = "Usage: vsense #{@command} <environment name>"
      opts.on_tail("-h", "--help", "Show this message") do
        STDERR.puts opts
        exit
      end
    end
  end

  def validate()
    super
    if ([@command] &  ['start','stop','status']).empty?
      STDERR.puts "Unrecognized command: #{@command}".red
      exit 1
    end
    if !File.exists?(@env_dir)
      STDERR.puts "Environment #{@args[0]} not found".red
      exit 1
    end
    if @command == 'start' and settings()['type'] == 'build'
      if !File.exists?(File.join(@env_dir,'bigsense.pub')) or !File.exists?(File.join(@env_dir,'bigsense.sec'))
        STDERR.puts "Build PGP Keys are missing. You must run ./vsense genkeys #{@args[0]}".red
        exit 1
      end
    end
    if @command == 'start' and settings()['type'] == 'infrastructure'
      if !File.exists?(File.join(@env_dir,'bigsense-ssl.key')) or !File.exists?(File.join(@env_dir,'bigsense-ssl.pem'))
        STDERR.puts "SSL Keys are missing. You must run ./vsense genkeys #{@args[0]}".red
        exit 1
      end
    end
  end

  def run()
    super
    case @command
      when 'start'
        vcmd = 'up'
      when 'stop'
        vcmd = 'halt'
      when 'status'
        vcmd = 'status'
    end
    Vagrant.run_cmd(@env_dir, vcmd)
  end


end