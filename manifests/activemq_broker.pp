# This class prepares an ActiveMQ middleware service for use by MCollective.
class site::activemq_broker (
  $activemq_memoryusage = '200 mb',
  $activemq_storeusage  = '1 gb',
  $activemq_tempusage   = '1 gb',
  $activemq_console     = false,
  $activemq_confdir     = undef,
) inherits site {

  # We need to know somewhat for sure exactly what configuration directory
  # will be used for ActiveMQ in order to correctly build the template.
  $confdir = $activemq_confdir ? {
    default => $activemq_confdir,
    undef   => $::osfamily ? {
      'Debian' => '/etc/activemq/instances-available/mcollective',
      default  => '/etc/activemq',
    },
  }

  # Set up and contain the ActiveMQ server using the puppetlabs/activemq
  # module
  class { '::activemq':
    instance      => 'mcollective',
    server_config => template('site/activemq_template.erb'),
  }
  contain 'activemq'

  # Set up SSL configuration. Use copies of the keys specified.
  file { "${confdir}/ca.pem":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0444',
    source  => $site::ssl_server_ca,
    require => Class['activemq::packages'],
  }
  file { "${confdir}/server_cert.pem":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0444',
    source  => $site::ssl_server_cert,
    require => Class['activemq::packages'],
  }
  file { "${confdir}/server_private.pem":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0400',
    source  => $site::ssl_server_private,
    require => Class['activemq::packages'],
  }

  java_ks { 'mcollective:truststore':
    ensure       => 'latest',
    certificate  => "${confdir}/ca.pem",
    target       => "${confdir}/truststore.jks",
    password     => 'puppet',
    trustcacerts => true,
    notify       => Class['activemq::service'],
    require      => File["${confdir}/ca.pem"],
  } ->

  file { "${confdir}/truststore.jks":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0400',
    require => Class['activemq::packages'],
    before  => Java_ks['mcollective:keystore'],
  }

  java_ks { 'mcollective:keystore':
    ensure       => 'latest',
    certificate  => "${confdir}/server_cert.pem",
    private_key  => "${confdir}/server_private.pem",
    target       => "${confdir}/keystore.jks",
    password     => 'puppet',
    trustcacerts => true,
    before       => Class['activemq::service'],
    require      => [
      File["${confdir}/server_cert.pem"],
      File["${confdir}/server_private.pem"],
    ],
  } ->
  file { "${confdir}/keystore.jks":
    owner   => 'activemq',
    group   => 'activemq',
    mode    => '0400',
    require => Class['activemq::packages'],
    before  => Class['activemq::service'],
  }

}
