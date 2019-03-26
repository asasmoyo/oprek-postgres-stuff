bash 'create replication user' do
  user 'postgres'
  code <<~EOF
    psql -c "select usename from pg_catalog.pg_user" -t -A | grep replicator \
      || psql -c "create user replicator with replication;"
  EOF
end

file '/etc/postgresql/11/main/conf.d/synchronous_standby.conf' do
  owner 'postgres'
  group 'postgres'
  mode '0600'
  content <<~EOF
    synchronous_standby_names = 'walreceiver_slave1'
  EOF
  notifies :restart, 'service[postgresql]', :immediately
end
