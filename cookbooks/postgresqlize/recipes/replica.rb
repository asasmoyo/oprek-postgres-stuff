include_recipe '::install'
include_recipe '::scripts'

service 'postgresql' do
  action [:stop]
  not_if { ::File.exist?('/var/lib/postgresql/11/main/.managed') }
end

directory '/var/lib/postgresql/11/main' do
  recursive true
  action :delete
  not_if { ::File.exist?('/var/lib/postgresql/11/main/.managed') }
end

execute 'copy db from master if haven\'t' do
  user 'root'
  command <<~EOF
    rm -rf /var/lib/postgresql/11/main
    pg_basebackup --pgdata=/var/lib/postgresql/11/main --progress --verbose --host=postgresql-master.service.consul --username=replicator
    touch /var/lib/postgresql/11/main/.managed
    chown -R postgres:postgres /var/lib/postgresql/11/main
    chmod -R u=rwX,g=rX,o-rwx /var/lib/postgresql/11/main
    chmod 750 /var/lib/postgresql/11/main
  EOF
  not_if { ::File.exist?('/var/lib/postgresql/11/main/.managed') }
  notifies :restart, 'service[postgresql]', :delayed
end

file '/var/lib/postgresql/11/main/recovery.conf' do
  owner 'postgres'
  group 'postgres'
  mode '0640'
  content <<~EOF
    standby_mode = 'on'
    primary_conninfo = 'user=replicator application_name=walreceiver_#{node.name} passfile=''/var/lib/postgresql/.pgpass'' host=#{node[:postgresqlize][:replication_upstream]} port=5432 sslmode=prefer sslcompression=0 krbsrvname=postgres target_session_attrs=any'
    restore_command = 'rsync -az satpam@wal-storage.node.consul:~/storage/%f %p'
  EOF
  notifies :restart, 'service[postgresql]', :delayed
end

# make sure it starts
service 'postgresql' do
  action [:start]
end
