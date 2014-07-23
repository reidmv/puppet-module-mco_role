# This class should be applied to all servers, and sets up the MCollective
# server. It includes its parent class "site" and uses the parameters set
# there. Inheritance is used to ensure order of evaluation and exposition of
# parameters without needing to call "include".
#
# The default parameters come from the mco_role::params class for only one
# reason. It allows the user to OPTIONALLY use Hiera to set values in one place
# and have them propagate multiple related classes. This will only work if the
# parameters are set in Hiera. It will not work if the parameters are set from
# an ENC.
#
class mco_role::server (
  $middleware_hosts    = $mco_role::params::middleware_hosts,
  $middleware_ssl_port = $mco_role::params::middleware_ssl_port,
  $middleware_user     = $mco_role::params::middleware_user,
  $middleware_password = $mco_role::params::middleware_password,
  $main_collective     = $mco_role::params::main_collective,
  $collectives         = $mco_role::params::collectives,
  $connector           = $mco_role::params::connector,
  $ssl_server_cert     = $mco_role::params::ssl_server_cert,
  $ssl_server_private  = $mco_role::params::ssl_server_private,
  $ssl_ca_cert         = $mco_role::params::ssl_ca_cert,
) inherits mco_role::params {

  class { '::mcollective':
    securityprovider     => 'ssl',
    middleware_ssl       => true,
    middleware_hosts     => $middleware_hosts,
    middleware_ssl_port  => $middleware_ssl_port,
    middleware_user      => $middleware_user,
    middleware_password  => $middleware_password,
    main_collective      => $main_collective,
    collectives          => $collectives,
    connector            => $connector,
    ssl_server_public    => $ssl_server_cert,
    ssl_server_private   => $ssl_server_private,
    ssl_ca_cert          => $ssl_ca_cert,
  }

}
