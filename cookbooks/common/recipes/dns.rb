coredns_version = node['common']['coredns']['version']
coredns_url = "https://github.com/coredns/coredns/releases/download/v#{coredns_version}/coredns_#{coredns_version}_linux_amd64.tgz"

coredns_path = '/opt/coredns'
coredns_current = "#{coredns_path}/#{coredns_version}"
coredns_bin = "#{coredns_current}/coredns"

directory coredns_path do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

directory coredns_current do
  action :delete
  recursive true
  not_if { ::File.exist? coredns_bin }
end

coredns_download_path = "#{Chef::Config[:file_cache_path]}/coredns-#{coredns_version}.tgz"
remote_file coredns_download_path do
  source coredns_url
end

archive_file coredns_download_path do
  destination coredns_current
end

directory coredns_current do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

systemd_unit 'coredns.service' do
  content({
    Unit: {
      Description: 'CoreDNS DNS server',
      Documentation: 'https://coredns.io',
      After: 'network.target'
    },
    Service: {
      PermissionsStartOnly: 'true',
      LimitNOFILE: 1048576,
      LimitNPROC: 512,
      CapabilityBoundingSet: 'CAP_NET_BIND_SERVICE',
      AmbientCapabilities: 'CAP_NET_BIND_SERVICE',
      NoNewPrivileges: 'true',
      WorkingDirectory: coredns_path,
      ExecStart: "#{coredns_bin} -conf=#{coredns_path}/config",
      ExecReload: '/bin/kill -SIGUSR1 $MAINPID',
      ConditionFileIsExecutable: "#{coredns_bin}",
      Restart: 'on-failure'
    },
    Install: {
      WantedBy: 'multi-user.target'
    }
  })
  verify false
  action [:create, :start, :enable]
end

service 'coredns' do
  action :nothing
end

file "#{coredns_path}/config" do
  content <<~EOF
    consul:53 {
      bind 127.0.0.1
      forward . 127.0.0.1:8600
      cache 30
      errors
    }

    .:53 {
      bind 127.0.0.1
      forward . 8.8.8.8 8.8.4.4 1.1.1.1
      errors
    }
  EOF
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[coredns]'
end

service 'systemd-resolved' do
  action :nothing
end

file '/etc/systemd/resolved.conf' do
  content <<~EOF
    [Resolve]
    DNS=127.0.0.1
  EOF
  notifies :restart, 'service[systemd-resolved]'
end
