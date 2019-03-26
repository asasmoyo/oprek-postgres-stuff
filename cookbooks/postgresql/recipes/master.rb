bash 'create replication user' do
  user 'postgres'
  code <<~EOF
    psql -c "select usename from pg_catalog.pg_user" -t -A | grep replicator \
      || psql -c "create user replicator with replication;"
  EOF
end
