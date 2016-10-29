{% set oscodename = grains['oscodename'] %}
{% set master            = '10.1.0.33'   %}
{% set pod_cidr          = '10.2.0.0/16' %}
{% set service_cidr      = '10.3.0.0/16' %}
{% set host              = grains['host'] %}
{% set salt_root         = '/srv/salt' %}
{% import_yaml "config.yml" as config %} 
# kubeadm init --token E6kqRrU5.C0plu9V5qUYRDWnn --pod-network-cidr 10.2.0.0/16 --service-cidr 10.3.0.0/16
{% set release           = '-unstable' %} # empty for regular
{% set release           = ''          %} # empty for regular

/etc/apt/sources.list.d/kubernetes.list:
  file.managed:
    - contents: |
        deb http://apt.kubernetes.io/ kubernetes-{{oscodename}}{{release}} main
    - user: root
    - group: root
    - mode: 644

/etc/apt/trusted.gpg.d/:
  cmd.run:
    - name: curl -s http://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - 

kubernetes packages:
  pkg.installed:
    - refresh: true
    - pkgs:
        - git
        - kubelet
        - kubectl
        - kubeadm
        - kubernetes-cni
        - docker-engine
