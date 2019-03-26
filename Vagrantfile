# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-18.04"

  config.vm.define 'master' do |master|
    master.vm.hostname = 'master'
    master.vm.network 'private_network', ip: '10.11.12.11'
    master.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'common'
      chef.add_recipe 'postgresql::install'
      chef.add_recipe 'postgresql::master'
    end
  end
  config.vm.define 'slave1' do |slave1|
    slave1.vm.hostname = 'slave1'
    slave1.vm.network 'private_network', ip: '10.11.12.12'
    slave1.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'common'
      chef.add_recipe 'postgresql::install'
      chef.add_recipe 'postgresql::slave'
    end
  end
  config.vm.define 'slave2' do |slave2|
    slave2.vm.hostname = 'slave2'
    slave2.vm.network 'private_network', ip: '10.11.12.13'
    slave2.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'common'
      chef.add_recipe 'postgresql::install'
      chef.add_recipe 'postgresql::slave'
    end
  end
  config.vm.define 'wal_storage' do |storage|
    storage.vm.hostname = 'wal-storage'
    storage.vm.network 'private_network', ip: '10.11.12.14'
    storage.vm.provision 'chef_solo' do |chef|
      chef.add_recipe 'common'
      chef.add_recipe 'wal_storage'
    end
  end
end
