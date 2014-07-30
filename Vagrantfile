# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/trusty64"

  config.vm.define "bigsense" do |bigsense|
    bigsense.vm.network "forwarded_port", guest: 8181, host: 8181
    bigsense.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "2048"]
    end
    bigsense.vm.provision "ansible" do |ansible|
      ansible.playbook = "bigsense.yml"
    end
  end

  config.vm.define "repo" do |repo|
    repo.vm.provision "ansible" do |ansible|
      ansible.playbook = "repo.yml"
    end
  end

end
