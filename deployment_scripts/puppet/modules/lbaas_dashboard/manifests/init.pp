class lbaas_dashboard {

    package {'python-pip':
        ensure => installed,
    }

    package { 'git':
        ensure => installed,
    }

    file {'/tmp/python-barbicanclient-4.0.2.dev1.tar.gz':
        ensure => present,
        source => "puppet:///modules/lbaas_dashboard/python-barbicanclient-4.0.2.dev1.tar.gz",
    }

    file {'/tmp/neutron-lbaas-dashboard-1.0.1.dev2.tar.gz':
        ensure => present,
        source => "puppet:///modules/lbaas_dashboard/neutron-lbaas-dashboard-1.0.1.dev2.tar.gz",
    }

    exec {'install barbicanclient':
        command => 'pip install /tmp/python-barbicanclient-4.0.2.dev1.tar.gz',
        path    => '/usr/bin',
    }

    exec {'install lbaas dashboard':
        command => 'pip install /tmp/neutron-lbaas-dashboard-1.0.1.dev2.tar.gz',
        path    => '/usr/bin',
    }

    file {'/usr/share/openstack-dashboard/openstack_dashboard/enabled/_1481_project_ng_loadbalancersv2_panel.py':
        ensure => present,
        source => '/usr/local/lib/python2.7/dist-packages/neutron_lbaas_dashboard/enabled/_1481_project_ng_loadbalancersv2_panel.py',
    }

    exec {'enable loadbalancer':
        command => "sed -e 's|\x27enable_lb\x27: False|\x27enable_lb\x27: True|g' -i /etc/openstack-dashboard/local_settings.py",
        path    => '/bin',
    }

    Package<||> ->
    File['/tmp/python-barbicanclient-4.0.2.dev1.tar.gz'] ->
    File['/tmp/neutron-lbaas-dashboard-1.0.1.dev2.tar.gz'] ->
    Exec['install barbicanclient'] ->
    Exec['install lbaas dashboard'] ->
    File['/usr/share/openstack-dashboard/openstack_dashboard/enabled/_1481_project_ng_loadbalancersv2_panel.py'] ->
    Exec['enable loadbalancer']
}