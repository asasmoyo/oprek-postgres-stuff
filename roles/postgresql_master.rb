name 'postgresql_master'
run_list 'common::default', 'consulize::consul_server', 'postgresqlize::master'
