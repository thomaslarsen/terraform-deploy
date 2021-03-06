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

packages:
  - https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  - git
  - salt-master
  - salt-minion
  # - GitPython

write_files:
  - path: /etc/salt/master
    owner: root:root
    content: |
      autosign_file: /etc/salt/autosign.conf
      fileserver_backend:
        - git
      gitfs_remotes:
        - https://github.com/thomaslarsen/system-definition.git:
          - root: roots
        - https://github.com/thomaslarsen/salt-formula.git
        - https://github.com/saltstack-formulas/epel-formula
      gitfs_ssl_verify: False
      ext_pillar:
        - git:
          - https://github.com/thomaslarsen/resource-config.git:
            - root: config
          - https://github.com/thomaslarsen/system-config.git:
            - root: pillar

  - path: /etc/salt/minion
    owner: root:root
    content: |
      id: ${fqdn}
      master: ${fqdn}
      startup_states: 'highstate'
      master_tries: -1
      grains:
        role: ${role}
        zone: ${zone}
        vdc: ${vdc}
        class: ${class}

  - path: /etc/salt/autosign.conf
    owner: root:root
    content: |
      ${autosign}

runcmd:
  - yum -y install GitPython
  - systemctl start salt-master
  - sleep 5
  - systemctl start salt-minion
