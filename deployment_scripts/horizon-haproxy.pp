notice('MODULAR: detach-horizon/horizon-haproxy.pp')

$horizon_hash        = hiera_hash('horizon', {})
# enabled by default
$use_horizon         = pick($horizon_hash['enabled'], true)
$public_ssl_hash     = hiera_hash('public_ssl', {})
$ssl_hash            = hiera_hash('use_ssl', {})

$public_ssl          = get_ssl_property($ssl_hash, $public_ssl_hash, 'horizon', 'public', 'usage', false)
$public_ssl_path     = get_ssl_property($ssl_hash, $public_ssl_hash, 'horizon', 'public', 'path', [''])

$external_lb = hiera('external_lb', false)

ensure_resource('sysctl::value', 'net.ipv4.ip_forward', { value => '1' })

if ($use_horizon and !$external_lb) {

  $network_metadata = hiera_hash('network_metadata')

  $horizon_roles       =  ['primary-horizon', 'horizon']
  $horizon_nodes       = get_nodes_hash_by_roles($network_metadata,$horizon_roles)
  $horizon_address_map = get_node_to_ipaddr_map_by_network_role($horizon_nodes, 'horizon')
  $ipaddresses         = ipsort(values($horizon_address_map))
  $server_names        = keys($horizon_address_map)

  $public_virtual_ip   = hiera('horizon_vip')

  # configure horizon ha proxy
  class { '::openstack::ha::horizon':
    ipaddresses         => $ipaddresses,
    public_virtual_ip   => $public_virtual_ip,
    internal_virtual_ip => $public_virtual_ip,
    server_names        => $server_names,
    use_ssl             => $public_ssl,
    public_ssl_path     => $public_ssl_path,
  }
}