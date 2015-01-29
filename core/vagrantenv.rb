#!/usr/bin/env ruby

require 'yaml'

class VagrantEnv

  def initialize(global_yml, local_yml)
    @vars = YAML.load_file(local_yml)
    @vsense = YAML.load_file(global_yml)
  end

  # security

  def ssh_security_enabled?()
    not @vsense['security']['ssh_key_file'].nil?
  end

  def ssh_identity_key_file()
    @vsense['security']['ssh_key_file']
  end

  # end security

  def ip(server)
    @vars['servers'][server]['ip']
  end

  def ip_ext(server)
    @vars['servers'][server]['ip_ext']
  end

  def hostname(server)
    @vars['servers'][server]['hostname']
  end

  def aliases(server)
    ['%s.%s' %[@vars['servers'][server]['hostname'],@vars['domain']]]
  end

  def vbox_image(server)
    case @vars['servers'][server]['os']
      when 'ubuntu'
        return 'ubuntu/trusty64'
      when 'debian'
        return 'zauberpony/wheezy'
      when 'centos'
        return 'hansode/centos-7.0.1406-x86_64'
      when 'opensuse'
        return 'alchemy/opensuse-13.2-64'
    end
  end

end
