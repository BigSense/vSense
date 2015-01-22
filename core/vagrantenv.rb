#!/usr/bin/env ruby

require 'yaml'

class VagrantEnv

  def initialize(yml_file)
    @vars = YAML.load_file(yml_file)
  end

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
