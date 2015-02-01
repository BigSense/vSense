require 'optparse'
require 'pathname'
require_relative 'env'

class SecureAction < Action

  GPG_ID_FILE = File.join(Dir.home, '.password-store', '.gpg-id')

  def set_options()
    super
    @options = {}
    @opts = OptionParser.new do |opts|

      opts.banner = 'Usage: vsense secure [-s <key_file> ] [-p <gpg key id> [-f]]'

      opts.on('-s', '--ssh KEY', 'SSH identity for vagrant user in all new VMs') do |f|
        @options[:ssh_key_file] = f
      end

      opts.on('-p', '--pgp ID', 'ID of PGP key to use for password encryption') do |id|
        @options[:pgp_id] = id
      end

      opts.on('-f', '--force', "Overwrite existing PGP ID in #{GPG_ID_FILE}") do |f|
        @options[:force_pgp] = f
      end

      opts.on_tail("-h", "--help", "Show this message") do
        STDERR.puts opts
        exit
      end

    end
  end


  def validate()

    # we don't call super because secure doesn't require
    #  an environment name

    if not @options[:pgp_id] and not @options[:ssh_key_file]
      STDERR.puts @opts
      exit 1
    end

    if @args.length > 0
      STDERR.puts ('Unknown trailing arguments: %s' %[@args.drop(1)]).red
      exit 1
    end

    if @options[:force_pgp] and not @options[:pgp_id]
      STDERR.puts '-f/--force can only be used with -p/--pgp ID'.red
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

      if File.exists?(GPG_ID_FILE)
        lines = File.readlines(GPG_ID_FILE)
        if lines.length > 0 and lines[0].strip != @options[:pgp_id] and not @options[:force_pgp]
          STDERR.puts "PGP key ID in #{GPG_ID_FILE} is already set to #{lines[0].strip}.\n" \
                      "If you change this, you may not be able to access existing passwords.\n" \
                      "Use -f to force".red #TODO: implement -f
          exit 1
        end
      end

    end

    if @options[:ssh_key_file]
      if not File.exists?(@options[:ssh_key_file])
       STDERR.puts "Could not find SSH key file #{@options[:ssh_key_file]}".red
       exit 1
      end
      public_key = "#{@options[:ssh_key_file].pub}"
      if not File.exists?(public_key)
       STDERR.puts "Could not find matching SSH public key #{public_key}".red
       exit 1
      end
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
      File.open(GPG_ID_FILE,'w') do |f|
        f.write(@options[:pgp_id])
      end
    end

    puts "Note: Security only takes place during provisioning. Existing environments remain unchanged".cyan
    puts "      It is recommended you run ssh-agent and gpg-agent.".cyan
    puts "      Passwords are stored in #{GPG_ID_FILE} (see http://www.passwordstore.org/)".cyan

  end

end