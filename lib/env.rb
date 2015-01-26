require 'yaml'
require_relative "action"

class Environment

  ENV_FILE = File.join(Action::ENVS,'list.yml')
  @@settings = File.exists?(ENV_FILE) ? YAML.load_file(ENV_FILE) : []
  @@env_settings = @@settings['environments']

  def self.add(name,env_type)
    @@env_settings << { 'name' => name , 'type' => env_type } 
    save_env_list
  end

  def self.del(name)
    @@env_settings = @@env_settings.reject { |h| h['name'] == name }
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
      File.open(ENV_FILE, 'w') do |file|
        file.write(@@settings.to_yaml)
      end
    end

end