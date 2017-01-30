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
  - git
  - salt-master
  - salt-minion

write_files:
  - path: /root/.ssh/git_key
    owner: root:root
    permissions: '0600'
    content: |
      -----BEGIN RSA PRIVATE KEY-----
      MIIEpAIBAAKCAQEA1mxhxqzAAz2z4fHqp0wxp93fnQfUNTV/kCBQoNLreA/56ysg
      KgScHjQvwSKdTVcOWVuijpkknFhRhnL16CZvZ/SrE5dcFk6Eh9Msrl33tYh/dNnq
      sxk2rmKi3veXafyUFSL4DA7+G4NT/xLRfjACbJgAaKPI2pxukERDV9mJ8Jj+iBnV
      2BammfEK/x5aULkKCA1Zkv4u3qD0peVdhV5mLuyKDctZdt7G04xpczPzBB2HZxQv
      D+2yZMZ0U1vJQEgtpt8+zJDlelj+2R30H0Jloq48bHiIybWOqbvXH0LncAwDf9cN
      +PSv4DBfpcQY3I+mMaVXGi3cw8qEOajrECubCwIDAQABAoIBAQDK4+rwzu0xI+Vd
      2kaq3pHtwSehspK9dk2p1qn0Qx/Dj3pvZ3MbzxjaC49UNKibUdCmBOsf+xCFT5x0
      l7rPW+72crCd7Q6ZnNoSm2Mf6pJFF09jBf/qT+VJxNNQHv8KrpCAH4KOBnGzHuUP
      6oKH4G2qy3k3iiK3mGWV5MHEEndPS/inVIA4nfbL+mPJJODPkENc3SsFkRS5Ibz+
      l9fXfodHgnaxsRxc3D76+2nDD+XjQQELYzy3OCElra8QwbxJs7YFPXSyU2utUoDM
      6VZpdqXx7tUa8//SoAON0VLuZLXCvxP0HoFj4pU5AESoffJyYr8QB7M/6KiVKSUO
      iC9dzBgBAoGBAPun0fiOZL3aLewr6qcku7DNWkHDSLX21tB1HA9/ux+u3XQEHbbP
      ZWbTNBGzsoecL6s23KLYNs6EXUBc7mjorAVu+UsuzvG5Z+/n96FTHzpvyaxiJt0C
      GVF63AREJlY/4tGJtGLPTjJe+s4lFkw9eACX3QnDd+P9G/6K36x5QrgLAoGBANog
      BBBsfsVjCYQZysCLpQZ6dC3gu7ii3vjPSmBWbQCgJyLmls5W2wAIB711H9tzISXm
      hMMDkCY31dJtWZ9f2ZYbpZODCgoTexTKPIUEqCIhfCfFMPr/eWd7Tx4juG6cvxrc
      +eAcHB+yS8m1pEJbd4xKm6dzjy5Ns2rZv2UbIYkBAoGAD44xEW8j1QRugEG6sHg5
      zdTztkru7KiEYMBMarzXgT7a23gBqjIpr3BwsINuDqnd3HR4sOwyfxN5fCgCaKOx
      NmjEqhwLmK+AODkbenJb5M3SJoCurEyb6ghxHyZjREOQrqkXaGAuEjkCwclTFoVa
      LJc2h4r4lzQnDdXhu5SHRj8CgYEAhqsplzJE+nzwzRxXb5VH574GqKSNgasc2qSw
      mNYDKlW2k/elt/Mr9tL+ZFxBtO1Z09qEsRosD0x9uRNGN/2niuO60F4g/qOUY/uQ
      bde4LopZ6vv2B6FfRSJ+cG9BWRlxa5Zut4zjWDZuUDTTGxz5rCYL/9B63+2dDiUt
      47BifgECgYBIso5vtZNntIP3haZOYZ7GTnxMoPuoGMc0jBuoVIS8c0EmTIWkUAf8
      MUel+75mfXBHePEf/SYvTR4gCN/EOZOpgXJvpWHMP7ob9mA6DjzetUJhudPS7jtf
      JMu5VQbaQgx5KOb9NOi82z9UnmwgXfun9p+ih4qwwpQLlagqThIuhQ==
      -----END RSA PRIVATE KEY-----

  - path: /tmp/minion
    owner: root:root
    content: |
      id: ${fqdn}
      file_roots:
        base:
          - /srv/kickstart/bootstrap/roots
          - /srv/formulas/salt-formula
      pillar_roots:
        base:
          - /srv/pillar

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
        domain: ${domain}
        vdc: ${vdc}
        class: ${class}

  - path: /etc/salt/autosign.conf
    owner: root:root
    content: |
      ${autosign}

runcmd:
  - echo `ssh-keyscan github.com` >> /root/.ssh/known_hosts
  - mkdir -p /srv/kickstart /srv/formulas
  - ssh-agent bash -c 'ssh-add /root/.ssh/git_key; git clone -b ${branch} ${kickstart_url} /srv/kickstart'
  - git clone https://github.com/saltstack-formulas/salt-formula.git /srv/formulas/salt-formula
  - ln -s /srv/kickstart/salt/roots /srv/salt
  - ln -s /srv/kickstart/salt/pillar /srv/pillar
  - salt-call -c /tmp --local state.apply
  - systemctl restart salt-minion
