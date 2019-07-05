# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  # install chef from local deb
  config.vm.provision 'shell', inline: <<~EOF
    if ! which chef-solo; then
      sudo dpkg -i /vagrant/chefdk.deb
    fi

    export BERKSHELF_PATH=/vagrant/.berks
    cd /vagrant && berks install && berks vendor
  EOF

  config.vm.define 'wal_storage' do |storage|
    storage.vm.hostname = 'wal-storage'
    storage.vm.network 'private_network', ip: '10.11.12.14'
    storage.vm.provision 'chef_solo' do |chef|
      chef.cookbooks_path = 'berks-cookbooks'
      chef.roles_path = 'roles'
      chef.custom_config_path = 'chef.rb'
      chef.install = false
      chef.json = {
        'consul' => {
          'config' => {
            'retry_join' => ['10.11.12.11']
          }
        }
      }

      chef.add_role 'wal_storage'
    end
  end
  config.vm.define 'master' do |master|
    master.vm.hostname = 'master'
    master.vm.network 'private_network', ip: '10.11.12.11'
    master.vm.provision 'chef_solo' do |chef|
      chef.cookbooks_path = 'berks-cookbooks'
      chef.roles_path = 'roles'
      chef.custom_config_path = 'chef.rb'
      chef.install = false

      chef.add_role 'postgresql_master'
    end
  end
  config.vm.define 'slave1' do |slave1|
    slave1.vm.hostname = 'slave1'
    slave1.vm.network 'private_network', ip: '10.11.12.12'
    slave1.vm.provision 'chef_solo' do |chef|
      chef.cookbooks_path = 'berks-cookbooks'
      chef.roles_path = 'roles'
      chef.custom_config_path = 'chef.rb'
      chef.install = false
      chef.json = {
        'consul' => {
          'config' => {
            'retry_join' => ['10.11.12.11']
          }
        }
      }

      chef.add_role 'postgresql_sync_replica'
    end
  end
  config.vm.define 'slave2' do |slave2|
    slave2.vm.hostname = 'slave2'
    slave2.vm.network 'private_network', ip: '10.11.12.13'
    slave2.vm.provision 'chef_solo' do |chef|
      chef.cookbooks_path = 'berks-cookbooks'
      chef.roles_path = 'roles'
      chef.custom_config_path = 'chef.rb'
      chef.install = false
      chef.json = {
        'consul' => {
          'config' => {
            'retry_join' => ['10.11.12.11']
          }
        }
      }

      chef.add_role 'postgresql_async_replica'
    end
  end
end
