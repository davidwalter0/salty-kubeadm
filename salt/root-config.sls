/root/.ssh:
  file.directory:
    - dir_mode: 0700
    - user: root
    - group: root
    - makedirs: true
      
/root/.ssh/authorized_keys copy:
  file.copy:
    - name  : /root/.ssh/authorized_keys
    - source: /home/vagrant/.ssh/authorized_keys

/root/.ssh/authorized_keys:
  file.managed:
    - user: root
    - group: root
    - makedirs: true
    - mode: 0600

