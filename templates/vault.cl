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
  - unzip

salt_minion:
    conf:
      id: ${fqdn}
      grains:
        role: ${role}
        zone: ${zone}
        vdc: ${vdc}
        class: ${class}

      fileserver_backend:
        - git
      gitfs_remotes:
        - https://github.com/thomaslarsen/system-definition.git:
          - root: roots
        - https://github.com/thomaslarsen/salt-formula.git
        - https://github.com/saltstack-formulas/epel-formula
        - https://github.com/mitodl/vault-formula.git
      gitfs_ssl_verify: False
      ext_pillar:
        - git:
          - https://github.com/thomaslarsen/resource-config.git:
            - root: config
          - https://github.com/thomaslarsen/system-config.git:
            - root: pillar
