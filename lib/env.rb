require 'yaml'
require_relative "action"

class Environment

  ENV_FILE = File.join(Action::ENVS,'list.yml')
  @@env_settings = File.exists?(ENV_FILE) ? YAML.load_file(ENV_FILE) : {}

  def self.add_env(name,env_type)
    @@env_settings[name] = { 'type' => env_type } 
    save_env_list
  end

  def self.del_env(name)
    @@env_settings.delete(name)
    save_env_list
  end

  private

    def self.save_env_list()
      File.open(ENV_FILE, 'w') do |file|
        file.write(@@env_settings.to_yaml)
      end
    end

end