# -*- mode: ruby -*-
# vi: set ft=ruby :

# https://docs.vagrantup.com
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network "forwarded_port", guest: 80, host: 8000 # web-server
  config.vm.network "forwarded_port", guest: 5432, host: 5430 # postgresql

   config.vm.provider "virtualbox" do |vb|
     vb.gui = false
     vb.memory = "1500"
   end
end