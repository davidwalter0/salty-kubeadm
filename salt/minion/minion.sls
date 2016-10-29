master: master
default_include: /etc/salt/minion.d/*.conf
file_client: local
hash_type: sha256
pillar_roots:
  base:
    - /srv/salt/pillar

