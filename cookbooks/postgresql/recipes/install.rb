apt_repository 'postgresql' do
  uri           'http://apt.postgresql.org/pub/repos/apt/'
  distribution  'bionic-pgdg'
  components    ['main']
  key           'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
end

package 'postgresql-11' do
  action :install
end

service 'postgresql' do
  action :nothing
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

ssh_known_hosts_entry '10.11.12.14' do
  owner 'postgres'
  group 'postgres'
  mode '0600'
  file_location '/var/lib/postgresql/.ssh/known_hosts'
end

append_if_no_line 'listen to all interfaces' do
  path '/etc/postgresql/11/main/postgresql.conf'
  line "listen_addresses = '*'"
  notifies :restart, 'service[postgresql]', :immediately
end

append_if_no_line 'replicator in pg_hba' do
  path '/etc/postgresql/11/main/pg_hba.conf'
  line 'host replication replicator 10.11.12.0/24 trust'
end

cookbook_file '/etc/postgresql/11/main/conf.d/wal.conf' do
  source 'wal.conf'
  user 'postgres'
  group 'postgres'
  mode '0600'
  notifies :restart, 'service[postgresql]', :immediately
end

cookbook_file '/etc/postgresql/11/main/conf.d/log.conf' do
  source 'wal.conf'
  user 'postgres'
  group 'postgres'
  mode '0600'
  notifies :restart, 'service[postgresql]', :immediately
end
