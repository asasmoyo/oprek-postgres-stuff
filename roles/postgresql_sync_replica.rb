name 'postgresql_sync_replica'
run_list 'common::default', 'consulize::consul_client', 'postgresqlize::replica_sync'
