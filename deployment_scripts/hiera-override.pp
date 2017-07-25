notice('MODULAR: detach-horizon/hiera-override.pp')

$plugin_data = hiera('fuel-plugin-detach-horizon', undef)
$hiera_dir              = '/etc/hiera/plugins'
$plugin_name            = 'fuel-plugin-detach-horizon'
$plugin_yaml            = "${plugin_name}.yaml"

if $plugin_data {
  $network_metadata = hiera_hash('network_metadata')
  $remote_keystone  = $plugin_data['remote_keystone']

  $horizon_roles       =  ['primary-horizon', 'horizon']
  $horizon_nodes       = get_nodes_hash_by_roles($network_metadata,
    $horizon_roles)
  $horizon_address_map = get_node_to_ipaddr_map_by_network_role($horizon_nodes, 'keystone/api')
  $horizon_nodes_ips   = ipsort(values($horizon_address_map))
  $horizon_nodes_names = keys($horizon_address_map)

  $memcached_addresses = ipsort(values(get_node_to_ipaddr_map_by_network_role($horizon_nodes,'mgmt/memcache')))

  $roles = join(hiera('roles'), ',')
  case $roles {
    /horizon/: {
      $corosync_roles = $horizon_roles
      $colocate_haproxy    = 'false'
      $deploy_vrouter      = 'false'
    }
  }

  $horizon_vip = $network_metadata['vips']['public_horizon_vip']['ipaddr']


  $calculated_content = inline_template('
<% if !@horizon_nodes_ips.empty? -%>
horizon_ipaddresses:
<%
@horizon_nodes_ips.each do |horizon_ip|
%>  - <%= horizon_ip %>
<% end -%>
<% end -%>
<% if !@horizon_nodes_names.empty? -%>
horizon_names:
<%
@horizon_nodes_names.each do |horizon_name|
%>  - <%= horizon_name %>
<% end -%>
<% end -%>
memcached_addresses:
<%
@memcached_addresses.each do |maddr|
%>  - <%= maddr %>
<% end -%>
<% if @corosync_roles -%>
corosync_roles:
<%
@corosync_roles.each do |crole|
%>  - <%= crole %>
<% end -%>
<% end -%>
<% if @colocate_haproxy -%>
colocate_haproxy: <%= @colocate_haproxy %>
<% end -%>
service_endpoint: <%= @remote_keystone %>
management_vip: <%= @remote_keystone %>
horizon_vip: <%= @horizon_vip %>
')

  file { "${hiera_dir}/${plugin_yaml}":
    ensure  => file,
    content => "${calculated_content}\n",
  }

}
