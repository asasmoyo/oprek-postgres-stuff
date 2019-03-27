user 'satpam' do
  home '/home/satpam'
  shell '/bin/bash'
  action :create
end

group 'satpam' do
  members ['satpam']
  action :create
end

directory '/home/satpam/.ssh' do
  recursive true
  owner 'satpam'
  group 'satpam'
  mode '0700'
end

authorized_keys_path = '/home/satpam/.ssh/authorized_keys'
file authorized_keys_path do
  owner 'satpam'
  group 'satpam'
  mode '0600'
  action :touch
end

postgres_servers = ['master', 'slave1', 'slave2', 'slave3']
postgres_servers.each do |server|
  append_if_no_line "#{server} key in authorized keys" do
    path '/home/satpam/.ssh/authorized_keys'
    line ::File.read("/vagrant/keys/#{server}.pub")
  end
end

directory '/home/satpam/storage' do
  owner 'satpam'
  group 'satpam'
  mode '0700'
end
