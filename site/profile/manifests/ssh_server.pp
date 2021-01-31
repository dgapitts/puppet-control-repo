class profile::ssh_server {
  package {'openssh-server':
    ensure => present,
  }
  service { 'sshd':
    ensure => 'running',
    enable => 'true',
  }
  ssh_authorized_key { 'puppetmaster':
    ensure => present,
    user   => 'root',
    type   => 'ssh-rsa',
    key    => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDEG0tZUQwPDpOVEgMR+RXoxE5lhjaGVEdHUtsdD5Or70I4C/edvXpPqauKEOAzLjNleTuJmnG+Ozq8bOaSE9NFd758CYqM2swVMfNqvFmilQlg8/yaKF3EzuGdXK5gx6mo/XizkuliCTtX5RxNgmVEIcYzOg/1zx8XSsBiWyHNPax9JX2s00DM4dc1UOssTiwchFjOprhg1cQQETsGnQaLoZHZneWtZYMKZBXjo5BntyIK8KybJLvOyKIXnKYbQ1nO57WbC2U2BXHNjKrts/DXkyW0rK6ljxD3eK04lSkeGT5A5g3/a92LwhesQJDMsi4IUNwNNXO1Onr2hdkJtoiJ',
  }  
}
