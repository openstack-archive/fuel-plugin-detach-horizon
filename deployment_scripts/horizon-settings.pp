notice('MODULAR: detach-horizon/horizon-settings.pp')


#Customizations all in one trash bin

$plugin_hash      = hiera('fuel-plugin-detach-horizon')
$login_domains    = $plugin_hash['login_domains']
$grafana_user     = $plugin_hash['grafana_user']
$grafana_password = $plugin_hash['grafana_password']
$grafana_url      = $plugin_hash['grafana_url']
$grafana_use_ssl  = $plugin_hash['grafana_use_ssl']
$kibana_url       = $plugin_hash['kibana_url']
$hidden_roles     = $plugin_hash['hidden_roles']
$default_role     = $plugin_hash['default_role']

$db_name     = $plugin_hash['db_name']
$db_username = $plugin_hash['db_username']
$db_password = $plugin_hash['db_password']
$db_host     = $plugin_hash['db_host']

$reports_user     = $plugin_hash['reports_user']
$reports_password = $plugin_hash['reports_password']
$reports_tenant   = $plugin_hash['reports_tenant']

$service_endpoint        = hiera('service_endpoint')
$ssl_hash               = hiera_hash('use_ssl', {})
$internal_auth_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'protocol', 'http')
$internal_auth_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'internal', 'hostname', [$service_endpoint, $management_vip])
$internal_auth_port     = '35357'
$keystone_api           = 'v3'
$keystone_url           = "${internal_auth_protocol}://${internal_auth_address}:${internal_auth_port}/${keystone_api}"

$ram_allocation_ratio  = $plugin_hash['ram_allocation_ratio']
$cpu_allocation_ratio  = $plugin_hash['cpu_allocation_ratio']
$disk_allocation_ratio = $plugin_hash['disk_allocation_ratio']

file_line { 'grafana_user':
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "GRAFANA_USER = ${grafana_user}",
  match             => "GRAFANA_USER\s?=",
}

file_line { 'grafana_password':
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "GRAFANA_PASSWORD = ${grafana_password}",
  match             => "GRAFANA_PASSWORD\s?=",
}

file_line { 'grafana_url':
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "GRAFANA_URL = ${grafana_url}",
  match             => "GRAFANA_URL\s?=",
}

if $grafana_use_ssl {
  file_line { 'grafana_use_ssl':
    ensure            => present,
    path              => '/etc/openstack-dashboard/local_settings.py',
    line              => "GRAFANA_USE_SSL = True",
    match             => "GRAFANA_USE_SSL\s?=",
  }
}

file_line { 'kibana_url':
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "KIBANA_URL = ${kibana_url}",
  match             => "KIBANA_URL\s?=",
}


file_line { 'login_domains':
    ensure            => present,
    path              => '/etc/openstack-dashboard/local_settings.py',
    line              => "LOGIN_DOMAINS = ${login_domains}",
    match             => "LOGIN_DOMAINS\s?=",
}

file_line { 'session_timeout':
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => 'SESSION_TIMEOUT = 43200',
  match             => "SESSION_TIMEOUT\s?=",
}

file_line { 'hidden_roles':
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "OPENSTACK_HIDDEN_KEYSTONE_ROLES = ${hidden_roles}",
  match             => "OPENSTACK_HIDDEN_KEYSTONE_ROLES\s?=",
}

file_line { 'default_role':
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "OPENSTACK_KEYSTONE_DEFAULT_ROLE = ${default_role}",
  match             => "OPENSTACK_KEYSTONE_DEFAULT_ROLE\s?= ${default_role}",
}

file_line { 'elasticsearch_url': 
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "ELASTIC_SEARCH_HOST = 'https://kibana.lma.mos.cloud.sbrf.ru:9200'",
  match             => "ELASTIC_SEARCH_HOST\s?=",
}

file_line { 'elasticsearch_search_index': 
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "ELASTIC_SEARCH_INDEX = 'notification-*'",
  match             => "ELASTIC_SEARCH_INDEX\s?=",
}

$db_json_string = "DATABASES = {'default': {'ENGINE': 'django.db.backends.mysql',
                         'NAME': '${db_name}',
                         'USER': '${db_username}',
                         'PASSWORD': '${db_password}',
                         'HOST': '${db_host}'}}"
file_line { 'database':
    ensure => present,
    path => '/etc/openstack-dashboard/local_settings.py',
    line => $db_json_string,
    match => "DATABASES\s?=",
    multiple => false,
}

$reports_json_string = "REPORTS_OPENSTACK_CREDS = {
    'user': '${reports_user}',
    'password': '${reports_password}',
    'auth_url': '${keystone_url}',
    'tenant': '${reports_tenant}',
}" 

file_line { 'reports':
    ensure => present,
    path => '/etc/openstack-dashboard/local_settings.py',
    line => $reports_json_string,
    match => "REPORTS_OPENSTACK_CREDS\s?=",
    multiple => false,
}

$allocation_ratio_string = "ALLOCATION_RATIO = {
    'ram': ${ram_allocation_ratio},
    'cores': ${cpu_allocation_ratio},
    'local_gb': ${disk_allocation_ratio}
}"

file_line { 'ratio':
    ensure => present,
    path => '/etc/openstack-dashboard/local_settings.py',
    line => $allocation_ratio_string,
    match => "ALLOCATION_RATIO\s?=",
    multiple => false,
}

file_line { 'reports_log':
  ensure            => present,
  path              => '/etc/openstack-dashboard/local_settings.py',
  line              => "SBR_REPORTS_LOGFILE = '/var/log/sbr_reports.log'",
  match             => "SBR_REPORTS_LOGFILE\s?=",
}

service { apache2:
  ensure => 'running'
}

File_line<||> ~> Service[apache2]