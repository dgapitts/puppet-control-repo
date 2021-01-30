# puppet-control-repo

This git repo is for my puppet training purposing:
* I've been following https://www.linkedin.com/learning/learning-puppet 
* This repo is to be used in conjunction with the puppetmaster vagrant vm deployed here https://github.com/dgapitts/vagrant-puppet 
* In v0.02 of the vagrant-pupppet git repo, is hardcoded link to this puppet-control-repo.git repo (this can be relatively easily changed and is acceptible for training purposes)
```
  # v0.02 r10k setup and linking to remote github repo

  echo '*** r10k setup and linking to remote repo https://github.com/dgapitts/puppet-control-repo.git'
  mkdir /etc/puppetlabs/r10k
  cat /vagrant/r10k.yaml > /etc/puppetlabs/r10k/r10k.yaml
```
* v0.01 of this puppet-control-repo covers project covers initial setup (details below)
* v0.02 will include hard coding the puppetmaster public ssh-key (to be completed)

## v0.01  initial setup

### on puppetmaster get latest code (r10k) and run puppet agent
```
[puppetmaster:root:~] # r10k deploy environment -p
[puppetmaster:root:~] # puppet agent -t
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter]/ensure: created
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/docker.rb]/ensure: defined content as '{md5}747c341ab2327cf5711de2adbfd7afcb'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/docker_hosts.rb]/ensure: defined content as '{md5}8270534b8b27c695f54498a4a61ac127'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/facter_dot_d.rb]/ensure: defined content as '{md5}37426ce465bf4a86aef41da3367b7d89'
Notice: /File[/opt/puppetlabs/puppet/cache/lib/facter/package_provider.rb]/ensure: defined content as '{md5}b17127f4c7f20443f6c85c4836745bac'
...
```

the above two a while to run and I also need to re-run to get past an initial

```
Notice: /Stage[main]/Dockeragent/Dockeragent::Image[agent]/Docker::Image[agent]/Exec[docker build -t agent /etc/docker/agent/]/returns: executed successfully
Info: Class[Dockeragent]: Unscheduling all events on Class[Dockeragent]
Notice: /Stage[main]/Profile::Agent_nodes/Dockeragent::Node[db01.puppet.vm]/Docker::Run[db01.puppet.vm]/File[/usr/local/bin/docker-run-db01.puppet.vm-start.sh]: Dependency Docker_network[dockeragent-net] has failures: true
Warning: /Stage[main]/Profile::Agent_nodes/Dockeragent::Node[db01.puppet.vm]/Docker::Run[db01.puppet.vm]/File[/usr/local/bin/docker-run-db01.puppet.vm-start.sh]: Skipping because of failed dependencies
Warning: /Stage[main]/Profile::Agent_nodes/Dockeragent::Node[db01.puppet.vm]/Docker::Run[db01.puppet.vm]/File[/usr/local/bin/docker-run-db01.puppet.vm-stop.sh]: Skipping because of failed dependencies
Warning: /Stage[main]/Profile::Agent_nodes/Dockeragent::Node[db01.puppet.vm]/Docker::Run[db01.puppet.vm]/File[/etc/systemd/system/docker-db01.puppet.vm.service]: Skipping because of failed dependencies
Warning: /Stage[main]/Profile::Agent_nodes/Dockeragent::Node[db01.puppet.vm]/Docker::Run[db01.puppet.vm]/Exec[docker-db01.puppet.vm-systemd-reload]: Skipping because of failed dependencies
...
```

I googled for "Dependency Docker_network[dockeragent-net] has failures" but didn't find much.

By chance I reran (to review any 'docker ps' details)  and the second time it worked

```
[puppetmaster:root:~] # for i in {1..100};do docker ps;sleep 1;done
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS     NAMES
c89d5f577cf3   agent     "/usr/lib/systemd/sy…"   32 seconds ago   Up 30 seconds             db02.puppet.vm
5e713642b7ea   agent     "/usr/lib/systemd/sy…"   33 seconds ago   Up 31 seconds             db01.puppet.vm
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS     NAMES
c89d5f577cf3   agent     "/usr/lib/systemd/sy…"   33 seconds ago   Up 31 seconds             db02.puppet.vm
5e713642b7ea   agent     "/usr/lib/systemd/sy…"   34 seconds ago   Up 32 seconds             db01.puppet.vm
```



### on docker node (on puppet control) get latest code via r10k and run puppet agent


The first run of puppet agent creates a new SSL cert
```
[puppetmaster:root:~] # docker exec -it db01.puppet.vm bash
[root@db01 /]# facter ipaddress
172.18.0.2
[root@db01 /]# puppet agent -t
Info: Creating a new SSL key for db01.puppet.vm
Info: Caching certificate for ca
Info: csr_attributes file loading from /etc/puppetlabs/puppet/csr_attributes.yaml
Info: Creating a new SSL certificate request for db01.puppet.vm
Info: Certificate Request fingerprint (SHA256): 95:E7:90:36:75:7A:59:3F:FF:D5:04:CD:7B:03:D1:D2:69:07:45:5C:61:80:03:F4:1C:05:41:C8:E7:9A:59:21
Info: Caching certificate for ca
Exiting; no certificate found and waitforcert is disabled
```

we need to switch back to the puppetmaster to add this cert

```
[root@db01 /]# exit
exit
[puppetmaster:root:~] # puppetserver ca list
Requested Certificates:
    db01.puppet.vm       (SHA256)  95:E7:90:36:75:7A:59:3F:FF:D5:04:CD:7B:03:D1:D2:69:07:45:5C:61:80:03:F4:1C:05:41:C8:E7:9A:59:21
[puppetmaster:root:~] # puppetserver ca sign --certname  db01.puppet.vm
Successfully signed certificate request for db01.puppet.vm
```
and now we can run puppet 
```
[puppetmaster:root:~] # docker exec -it db01.puppet.vm bash
[root@db01 /]# puppet agent -t
Info: Caching certificate for db01.puppet.vm
Info: Caching certificate_revocation_list for ca
Info: Caching certificate for db01.puppet.vm
Info: Using configured environment 'production'
Info: Retrieving pluginfacts
Info: Retrieving plugin
Notice: /File[/var/opt/lib/pe-puppet/lib/facter]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/docker.rb]/ensure: defined content as '{md5}747c341ab2327cf5711de2adbfd7afcb'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/docker_hosts.rb]/ensure: defined content as '{md5}8270534b8b27c695f54498a4a61ac127'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/facter_dot_d.rb]/ensure: defined content as '{md5}37426ce465bf4a86aef41da3367b7d89'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/package_provider.rb]/ensure: defined content as '{md5}b17127f4c7f20443f6c85c4836745bac'
Notice: /File[/var/opt/lib/pe-puppet/lib/facter/pe_version.rb]/ensure: defined content as '{md5}b2c9b4cbc4b69c2a377770f7189d3e94'
...
Notice: /File[/var/opt/lib/pe-puppet/locales/ja]/ensure: created
Notice: /File[/var/opt/lib/pe-puppet/locales/ja/puppetlabs-concat.po]/ensure: defined content as '{md5}c9dad056a76901974ded7b150267573a'
Notice: /File[/var/opt/lib/pe-puppet/locales/ja/puppetlabs-stdlib.po]/ensure: defined content as '{md5}805e5d893d2025ad57da8ec0614a6753'
Info: Loading facts
Info: Caching catalog for db01.puppet.vm
Info: Applying configuration version '1612038833'
Notice: /Stage[main]/Profile::Base/User[admin]/ensure: created
Info: Creating state file /var/opt/lib/pe-puppet/state/state.yaml
Notice: Applied catalog in 0.65 seconds
```
and it appears we psql 9.2 installed

```
[root@db01 /]# psql --version
psql (PostgreSQL) 9.2.24
```
