scripts_dir = '/opt/scripts/postgresql'
directory scripts_dir do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

cookbook_file "#{scripts_dir}/current_state.sh" do
  source 'current_state.sh'
  owner 'root'
  group 'root'
  mode '0755'
end
