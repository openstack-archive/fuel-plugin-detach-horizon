notice('MODULAR: detach-horizon/muranodashboard.pp')

$murano_hash                = hiera_hash('murano', {})
if $murano_hash['enabled'] {
	$murano_plugins             = pick($murano_hash['plugins'], {})
	$murano_settings_hash       = hiera_hash('murano_settings', {})

	if $murano_plugins and $murano_plugins['glance_artifacts_plugin'] and $murano_plugins['glance_artifacts_plugin']['enabled'] {
	  $packages_service = 'glance'
	  $enable_glare     = true
	} else {
	  $packages_service = 'murano'
	  $enable_glare     = false
	}

	$repository_url = has_key($murano_settings_hash, 'murano_repo_url') ? {
	  true    => $murano_settings_hash['murano_repo_url'],
	  default => 'http://storage.apps.openstack.org',
	}

	class { '::murano::dashboard':
	  enable_glare => $enable_glare,
	  repo_url     => $repository_url,
	  sync_db      => false,
	}
}
