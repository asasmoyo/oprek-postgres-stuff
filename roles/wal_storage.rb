name 'wal_storage'
run_list 'common::default', 'consulize::consul_client', 'wal_storage::default'
