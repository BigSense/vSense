#!/usr/bin/env ruby

require 'yaml'

class VagrantEnv

  def initialize(yml_file)
    @vars = YAML.load_file(yml_file)
  end

  def ip(server)
    @vars['servers'][server]['ip']
  end

  def hostname(server)
    @vars['servers'][server]['hostname']
  end

  def aliases(server)
    ['%s.%s' %[@vars['servers'][server]['hostname'],@vars['domain']]]
  end

end
