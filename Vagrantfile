# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

require 'yaml'
vars = YAML.load_file('environment.yml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  config.vm.define "bigsense" do |bigsense|

    bigsense.vm.network :private_network, ip: '10.11.1.1'
    bigsense.vm.hostname = 'server'
    bigsense.hostmanager.aliases = %w(server.bigsense.io)

    bigsense.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
    end
    bigsense.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/bigsense.yml"
    end
  end

  config.vm.define "repo" do |repo|
    bigsense.vm.network :private_network, ip: '10.11.1.2'
    repo.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/repo.yml"
    end
  end

  config.vm.define "build" do |build|
    bigsense.vm.network :private_network, ip: '10.11.1.3'
    build.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
    end
    build.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/build.yml"
    end
  end

  config.vm.define "win2012sql" do |win2012sql|
    config.vm.box = "Windows2012R2"
    config.vm.communicator = "winrm"
    config.vm.network "forwarded_port", host: 3389, guest: 3389
  end

end
