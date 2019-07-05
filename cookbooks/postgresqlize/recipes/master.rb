include_recipe '::install'
include_recipe '::scripts'

postgresql_server_install 'initialize postgresql cluster' do
  version '11'
  port 5432
  action :create
end

systemd_unit 'postgresql.service' do
  action :start
end

postgresql_user 'replicator' do
  replication true
  action :create
end

postgresql_access 'access for replicator user' do
  access_type 'host'
  access_db 'replication'
  access_user 'replicator'
  access_addr '10.11.12.0/24'
  access_method 'trust'
end

postgresql_user 'consul' do
  createdb true
  action :create
end

postgresql_access 'consul for check scripts' do
  access_type 'local'
  access_db 'consul'
  access_user 'consul'
  access_method 'peer'
end

service 'consul-template' do
  action :nothing
end

file '/etc/postgresql/11/main/conf.d/synchronous_standby.conf' do
  owner 'postgres'
  group 'postgres'
  mode '660'
  action :touch
end

file '/opt/consul-template/templates/synchronous_standby.conf.ctmpl' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<~EOF
    synchronous_standby_names = '{{ range $key, $val := service "postgresql-async-replica" }}{{ if $key }},{{ end }}walreceiver_{{ $val.Node }}{{ end }}'
  EOF
  notifies :restart, 'service[consul-template]'
end

file '/opt/consul-template/config/synchronous_standby.hcl' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<~EOF
    template {
      source = "/opt/consul-template/templates/synchronous_standby.conf.ctmpl"
      destination = "/etc/postgresql/11/main/conf.d/synchronous_standby.conf"
      command = "systemctl restart postgresql"
      error_on_missing_key = false
    }
  EOF
  notifies :restart, 'service[consul-template]'
end

consul_definition 'postgresql-master' do
  type 'service'
  parameters(
    port:  5432,
    check: {
      interval: '10s',
      timeout: '5s',
      args: [
        'bash',
        '-c',
        '/opt/scripts/postgresql/current_state.sh | grep master'
      ]
    }
  )
  notifies :reload, 'consul_service[consul]'
end
