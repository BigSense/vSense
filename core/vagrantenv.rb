#!/usr/bin/env ruby

require 'yaml'

class VagrantEnv

  def initialize(global_yml='../vsense.yml', local_yml='environment.yml')
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

  def ext_ip(server)
    @vars['servers'][server]['ext_ip']
  end

  def ext_iface(server)
    @vars['servers'][server]['ext_iface']
  end

  def hostname(server)
    @vars['servers'][server]['hostname']
  end

  def aliases(server)
    ['%s.%s' %[@vars['servers'][server]['hostname'],@vars['domain']]]
  end

  def vbox_for_server(server)
    return vbox_image @vars['servers'][server]['os']
  end

  def vbox_image(os)
    return @vsense['boxes'][os]
  end

end
