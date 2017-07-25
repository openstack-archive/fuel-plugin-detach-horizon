notice('MODULAR: detach-horizon/upgrade_horizon_packages.pp')


$packages = ['python-django-openstack-auth', 'python-django-horizon', 'openstack-dashboard', 'horizon-vendor-theme']

package{ $packages:
  ensure => 'latest'
}

package{'python-murano-dashboard':
  ensure => '1:3.0.0~rc1.dev196-1~u14.04+mos8+private1'
}

exec { 'apply_ui_changes':
  command   => "python /usr/share/openstack-dashboard/manage.py collectstatic --clear --noinput && python /usr/share/openstack-dashboard/manage.py compress",
  path      => '/usr/bin',
} ~> service { 'apache2': }

exec {'sync db':
  environment => ["PYTHONPATH=/usr/share/openstack-dashboard", "DJANGO_SETTINGS_MODULE=openstack_dashboard.settings"],
  command => 'django-admin migrate',
  path    => '/usr/bin',
}

Package<||> -> Exec['sync db'] -> Exec['apply_ui_changes']
