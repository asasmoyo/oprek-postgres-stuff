packages = [
  'rsync',
  'openssh-client',
  'htop',
  'sysstat',
]
package packages do
  action :install
end
