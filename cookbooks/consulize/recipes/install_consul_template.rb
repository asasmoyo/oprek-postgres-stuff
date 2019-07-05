version = node['consul-template']['version']
url = "https://releases.hashicorp.com/consul-template/#{version}/consul-template_#{version}_linux_amd64.tgz"

path = '/opt/consul-template'
config_path = "#{path}/config"
template_path = "#{path}/templates"
current_path = "#{path}/#{version}"
current_bin = "#{current_path}/consul-template"

directory path do
  owner 'root'
  owner 'root'
  mode '0755'
  recursive true
end

directory config_path do
  owner 'root'
  owner 'root'
  mode '0755'
  recursive true
end

directory template_path do
  owner 'root'
  owner 'root'
  mode '0755'
  recursive true
end

directory current_path do
  action :delete
  recursive true
  not_if { ::File.exist? current_bin }
end

download_path = "#{Chef::Config[:file_cache_path]}/consul-template-#{version}.tgz"
remote_file download_path do
  source url
end

archive_file download_path do
  destination current_path
end

directory current_path do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

service 'consul-template' do
  action :nothing
end

cookbook_file "#{config_path}/config.hcl" do
  source 'config.hcl'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :reload, 'service[consul-template]'
end

systemd_unit 'consul-template.service' do
  content <<~EOF
    [Unit]
    Description=Consul Template
    Documentation=https://github.com/hashicorp/consul-template
    After=network.target

    [Service]
    WorkingDirectory=#{path}
    ConditionFileIsExecutable=#{current_bin}
    ExecStart=#{current_bin} -config=#{config_path}
    Restart=on-failure
    KillSignal=SIGINT
    ExecReload=/bin/kill -s SIGHUP $MAINPID

    [Install]
    WantedBy=multi-user.target
  EOF
  action [:create, :start, :enable]
  notifies :restart, 'service[consul-template]'
end
