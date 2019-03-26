bash 'copy db from master if haven\'t' do
  user 'postgres'
  code <<~EOF
    if [[ -f /var/lib/postgresql/11/main/.managed ]]; then
      echo "done already"
      exit 0
    fi

    systemctl stop postgresql
    rm -rf /var/lib/postgresql/11/main
    pg_basebackup --pgdata=/var/lib/postgresql/11/main --write-recovery-conf --progress --verbose --host=10.11.12.11 --username=replicator
    echo 'rsync -az satpam@10.11.12.14:~/storage/%f %p' > /var/lib/postgresql/11/main/recovery.conf

    touch /var/lib/postgresql/11/main/.managed
  EOF
end
