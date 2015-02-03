require 'yaml'
require_relative "action"

class Environment

  DEFAULT_VIRTUALBOX_IMGS = { 
    'ubuntu' => 'ubuntu/trusty64',
    'debian' => 'zauberpony/wheezy',
    'centos' =>  'hansode/centos-7.0.1406-x86_64',
    'opensuse' => 'alchemy/opensuse-13.2-64' 
  }

  ENV_FILE = File.join(Action::ENVS,'vsense.yml')
  @@settings = File.exists?(ENV_FILE) ? YAML.load_file(ENV_FILE) : { 'environments' => [], 'security' => {}, 'boxes' => DEFAULT_VIRTUALBOX_IMGS }
  @@env_settings = @@settings['environments']
  @@sec_settings = @@settings['security']

  def self.add(name,env_type)
    @@env_settings << { 'name' => name , 'type' => env_type }
    save_env_list
  end

  def self.del(name)
    @@settings['environments'] = @@env_settings.reject { |h| h['name'] == name }
    save_env_list
  end

  def self.add_security(setting,value)
    @@settings['security'][setting] = value
  end

  def self.build_envs()
    @@env_settings.reject { |e| e['type'] != 'build' }.collect { |l| l['name'] }
  end

  def self.info(name)
    @@env_settings.reject { |h| h['name'] != name }
  end

  # security settings

  def self.pgp_id()
    @@sec_settings['pgp_id']
  end

  def self.pgp_id=(value)
    @@sec_settings['pgp_id'] = value
    save_env_list
  end

  def self.ssh_key_file()
    @@sec_settings['ssh_key_file']
  end

  def self.ssh_key_file=(value)
    @@sec_settings['ssh_key_file'] = value
    save_env_list
  end

  # end security

  def self.list()

    if @@env_settings.length == 0
      puts 'No environments. To create one, use ./vsense create'.red
      exit 0
    end

    cols = [ 'name' , 'type'  ]

    #Taken from http://ruby.about.com/od/examples/a/Csv-Example-Format-Strings-And-Printing-The-Ascii-Table.htm
    # TODO: make this more general

    # Determine column widths
    column_widths = {}
    cols.each do|c|
      column_widths[c] = [ c.length, *@@env_settings.map{|g| g[c].length } ].max
    end

    # Make the format string
    format = cols.map{|c| "%-#{column_widths[c]}s" }.join(' | ')

    # Print the table
    puts format % cols
    puts format.tr(' |', '-+') % column_widths.values.map{|v| '-'*v }

    @@env_settings.each do|g|
      puts format % cols.map{|c| g[c] }
    end

  end

  private

    def self.save_env_list()
      if not File.exists?(Action::ENVS)
        FileUtils.mkdir_p Action::ENVS
      end
      File.open(ENV_FILE, 'w') do |file|
        file.write(@@settings.to_yaml)
      end
    end

end