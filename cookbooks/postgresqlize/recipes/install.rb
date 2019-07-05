postgresql_server_install 'install postgresql binaries' do
  version '11'
  action :install
end

service 'postgresql' do
  action :start
end

postgresql_server_conf 'configure postgresql' do
  version '11'
  additional_config ({
    'listen_addresses' => '*',
    'include_dir' => 'conf.d',
    'wal_level' => 'replica',
    'wal_keep_segments' => 100,
    'max_wal_senders' => 20,
    'archive_mode' => 'on',
    'archive_command' => 'rsync -az %p satpam@wal-storage.node.consul:~/storage/',
    'log_checkpoints' => 'on',
    'log_connections' => 'on',
    'log_lock_waits' => 'on',
    'log_disconnections' => 'on',
    'log_line_prefix' => '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ',
    'log_temp_files' => 0,
    'log_autovacuum_min_duration' => 0,
  })
  notifies :restart, 'service[postgresql]', :immediately
end

directory '/etc/postgresql/11/main/conf.d' do
  user 'postgres'
  group 'postgres'
  recursive true
  mode '0755'
end

directory '/var/lib/postgresql/.ssh' do
  user 'postgres'
  group 'postgres'
  mode '0700'
end

file '/var/lib/postgresql/.ssh/id_rsa' do
  user 'postgres'
  group 'postgres'
  mode '0600'
  content ::File.read("/vagrant/keys/#{node.name}")
end

ssh_known_hosts_entry 'wal-storage.node.consul' do
  owner 'postgres'
  group 'postgres'
  mode '0600'
  file_location '/var/lib/postgresql/.ssh/known_hosts'
end
