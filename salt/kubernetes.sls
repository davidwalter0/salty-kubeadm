{% import_yaml "config.yml"   as config  %} 
{% import_yaml "settings.yml" as setting %}

/etc/apt/sources.list.d/kubernetes.list:
  file.managed:
    - contents: |
        deb http://apt.kubernetes.io/ kubernetes-{{setting.oscodename}}{{setting.release}} main
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
