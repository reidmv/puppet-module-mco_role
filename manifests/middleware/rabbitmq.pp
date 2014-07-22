# This class prepares a RabbitMQ middleware service for use by MCollective.
class mco_role::middleware::rabbitmq (
  $confdir           = '/etc/rabbitmq',
  $vhost             = $mco_role::rabbitmq_vhost,
  $delete_guest_user = false,
) inherits mco_role {

  # Set up SSL files. Use copies of the PEM keys specified as parameters.
  file { "${confdir}/ca.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0444',
    source => $mco_role::ssl_ca_cert,
  }
  file { "${confdir}/server_public.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0444',
    source => $mco_role::ssl_server_public,
  }
  file { "${confdir}/server_private.pem":
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0400',
    source => $mco_role::ssl_server_private,
  }

  # Install the RabbitMQ service using the puppetlabs/rabbitmq module
  class { '::rabbitmq':
    config_stomp      => true,
    delete_guest_user => $delete_guest_user,
    ssl               => true,
    stomp_port        => $mco_role::middleware_port,
    ssl_stomp_port    => $mco_role::middleware_ssl_port,
    ssl_cacert        => "${confdir}/ca.pem",
    ssl_cert          => "${confdir}/server_public.pem",
    ssl_key           => "${confdir}/server_private.pem",
  }
  contain rabbitmq

  # Configure the RabbitMQ service for use by MCollective
  rabbitmq_plugin { 'rabbitmq_stomp':
    ensure => present,
  } ->

  rabbitmq_vhost { $vhost:
    ensure => present,
  } ->

  rabbitmq_user { $mco_role::middleware_user:
    ensure   => present,
    admin    => false,
    password => $mco_role::middleware_password,
  } ->

  rabbitmq_user { $mco_role::middleware_admin_user:
    ensure   => present,
    admin    => true,
    password => $mco_role::middleware_admin_password,
  } ->

  rabbitmq_user_permissions { "${mco_role::middleware_user}@${vhost}":
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  } ->

  rabbitmq_user_permissions { "${mco_role::middleware_admin_user}@${vhost}":
    configure_permission => '.*',
  } ->

  rabbitmq_exchange { "mcollective_broadcast@${vhost}":
    ensure   => present,
    type     => 'topic',
    user     => $mco_role::middleware_admin_user,
    password => $mco_role::middleware_admin_password,
  } ->

  rabbitmq_exchange { "mcollective_directed@${vhost}":
    ensure   => present,
    type     => 'direct',
    user     => $mco_role::middleware_admin_user,
    password => $mco_role::middleware_admin_password,
  }

}
