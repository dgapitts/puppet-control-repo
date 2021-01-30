class profile::agent_nodes {
  include dockeragent
  dockeragent::node { 'db01.puppet.vm': }
  dockeragent::node { 'db02.puppet.vm': }
  host {'db02.puppet.vm':
    ensure => present,
    ip => '172.18.0.2',
  }
  host {'db01.puppet.vm':
    ensure => present,
    ip => '172.18.0.3',
  }
}
