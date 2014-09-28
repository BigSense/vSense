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
      ansible.playbook = "ansible/bigsense.yml"
    end
  end

  config.vm.define "repo" do |repo|
    repo.vm.network "forwarded_port", guest:80, host:8282
    repo.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/repo.yml"
    end
  end

  config.vm.define "build" do |build|
    build.vm.network "forwarded_port", guest:8080, host:8090
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
