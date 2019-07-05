ip = node['network']['interfaces']['enp0s8']['addresses'].keys[1]
node.default['consul']['config']['bind_addr'] = ip
node.default['consul']['config']['advertise_addr'] = ip

include_recipe 'consul::default'
