require 'optparse'
require 'pathname'
require_relative 'env'

class SecureAction < Action

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

    if not @options[:pgp_id] and not @options[:ssh_key_file]
      puts "here"
      STDERR.puts @opts
      exit 1
    end

    if @args.length > 0
      STDERR.puts ('Unknown trailing arguments: %s' %[@args.drop(1)]).red
      exit 1
    end

    if @options[:pgp_id]

      # FIXME: This sorta works. Partial mating could give us an invalid key

      cmd = "gpg --list-key #{@options[:pgp_id]}"
      out = `#{cmd} 2>&1`
      if $?.exitstatus != 0
        STDERR.puts out.red
        exit 1
      end
    end

    if @options[:ssh_key_file] and not File.exists?(@options[:ssh_key_file])
       STDERR.puts "Could not find SSH key file #{@options[:ssh_key_file]}".red
       exit 1
    end

  end

  def run()
    super
    if @options[:ssh_key_file]
      puts "Setting ssh identify file to #{@options[:ssh_key_file]}".green
      Environment::ssh_key_file = @options[:ssh_key_file]
    end

    if @options[:pgp_id]
      puts "Setting pgp ID to #{@options[:pgp_id]}".green
      Environment::pgp_id = @options[:pgp_id]
    end

    puts "\nNote: Security only takes place during provisioning. Existing environments remain unchanged".cyan
    puts "      It is recommended you run ssh-agent and gpg-agent".cyan
    puts "      Passwords are stored in ~/.password-store (see http://www.passwordstore.org/⟩".cyan

  end

end