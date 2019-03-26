bash 'copy db from master if haven\'t' do
  user 'postgres'
  code <<~EOF
    if [[ -f /var/lib/postgresql/11/main/.managed ]]; then
      exit 0
    fi

    systemctl stop postgresql
    rm -rf /var/lib/postgresql/11/main
    pg_basebackup --pgdata=/var/lib/postgresql/11/main --write-recovery-conf --progress --verbose --host=10.11.12.11 --username=replicator

    touch /var/lib/postgresql/11/main/.managed
  EOF
end

file '/var/lib/postgresql/11/main/recovery.conf' do
  content <<~EOF
    standby_mode = 'on'
    primary_conninfo = 'user=replicator application_name=walreceiver_#{node.name} passfile=''/var/lib/postgresql/.pgpass'' host=#{node[:postgresql][:replication_upstream]} port=5432 sslmode=prefer sslcompression=0 krbsrvname=postgres target_session_attrs=any'
    restore_command = 'rsync -az satpam@10.11.12.14:~/storage/%f %p'
  EOF
  notifies :restart, 'service[postgresql]', :immediately
end
