include_recipe '::replica'

consul_definition 'postgresql-async-replica' do
  type 'service'
  parameters(
    port:  5432,
    check: {
      interval: '10s',
      timeout: '5s',
      args: [
        'bash',
        '-c',
        '/opt/scripts/postgresql/current_state.sh | grep replica'
      ]
    }
  )
  notifies :reload, 'consul_service[consul]'
end
