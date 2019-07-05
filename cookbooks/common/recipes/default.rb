apt_update 'daily update apt cache' do
  frequency 60 * 60 * 24
  action :periodic
end

packages = [
  'rsync',
  'openssh-client',
  'htop',
  'nload',
  'sysstat',
  'tree',
  'jq',
]
package packages do
  action :install
end

include_recipe '::dns'
