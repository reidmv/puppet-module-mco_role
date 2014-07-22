# This class should be applied to all servers, and sets up the MCollective
# server. It includes its parent class "site" and uses the parameters set
# there. Inheritance is used to ensure order of evaluation and exposition of
# parameters without needing to call "include".
#
class mco_role::server inherits mco_role {

  class { '::mcollective':
    securityprovider     => 'ssl',
    middleware_ssl       => true,
    middleware_hosts     => $mco_role::middleware_hosts,
    middleware_ssl_port  => $mco_role::middleware_ssl_port,
    middleware_user      => $mco_role::middleware_user,
    middleware_password  => $mco_role::middleware_password,
    ssl_ca_cert          => $mco_role::ssl_server_ca,
    main_collective      => $mco_role::main_collective,
    collectives          => $mco_role::collectives,
    connector            => $mco_role::connector,
    ssl_server_public    => $mco_role::ssl_server_public,
    ssl_server_private   => $mco_role::ssl_server_private,
    ssl_server_ca        => $mco_role::ssl_server_ca,
  }

}
