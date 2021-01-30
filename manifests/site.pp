
node 'puppetmaster' {
  include role::master_server
  file {'/root/README':
    ensure => file,
    content => “basic test ${fqdn}”,
  }
}
node /^db/ {
  include role::db_server
}
