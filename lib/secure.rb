require 'optparse'
require 'pathname'

class Secure < Action 



  def set_options()
    super
    @options = {}
    @opts = OptionParser.new do |opts|

      opts.banner = 'Usage: vsense secure [-s <key_file> ] [-p <gpg key id>]'

      opts.on('-s', '--ssh KEY', 'SSH identity for vagrant user in all new VMs') do |f|
        @options[:ssh_key_file] = f
      end

      opts.on('-p', '--pgp ID', 'ID of PGP key to use for password encryption') do |id|
        @options[:pgp_id] = id
      end

      opts.on_tail("-h", "--help", "Show this message") do
        STDERR.puts opts
        exit
      end

    end
  end


  def validate()
  end

  def run()

    if @options[:ssh_key_file]
      Environment::add_security('ssh_key_file',@options[:ssh_key_file])
    end

  end

end