#cloud-config

hostname: ${hostname}
fqdn: ${fqdn}

yum_repos:
  saltstack-repo:
    name: SaltStack repo for RHEL/CentOS $releasever
    baseurl: https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest
    enabled: true
    gpgcheck: true
    gpgkey: https://repo.saltstack.com/yum/redhat/$releasever/$basearch/latest/SALTSTACK-GPG-KEY.pub

salt_minion:
  conf:
    master: ${saltmaster}
    id: ${fqdn}
    master_tries: -1
    startup_states: 'highstate'
    grains:
      role: ${role}
      zone: ${zone}
      domain: ${domain}
      vdc: ${vdc}
      class: ${class}
