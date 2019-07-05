node.default['consul']['config']['server'] = true
node.default['consul']['config']['bootstrap'] = true
node.default['consul']['config']['bootstrap_expect'] = 1
node.default['consul']['config']['ui'] = true

include_recipe '::install_consul'
include_recipe '::install_consul_template'
