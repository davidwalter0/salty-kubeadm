# config.yml might have number of nodes. . .
{% import_yaml "config.yml"   as config  %} 
{% import_yaml "settings.yml" as setting %}

/srv/salt/pillar:
  file.directory:
    # - user: root
    # - group: root
    - dir_mode: 755
    - makedirs: true

/etc/cni/net.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: true

{% for file in ['10-kubernetes-net.conf', '99-loopback.conf'] %}
/etc/cni/net.d/{{file}}:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - source:
        - salt://net.d/{{file}}
    - template: jinja
    - context :
        {{setting}}

{%endfor%}

{{setting.etc_kubernetes}}:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 0700
    - file_mode: 600

/etc/salt/minion.d/00-pillar-root.conf:
  file.managed:
    - mode: 644
    - makedirs: true
    - contents: |
        id: {{setting.host}}
{%-if config.kubeadm.kube_num_nodes > 0 %}        
        master: 
          - {{setting.master}}
{%-endif%}
        pillar_roots:
         base:
           - {{setting.pillar_root}}

/etc/salt/master.d/00-master-options.conf:
  file.managed:
    - mode: 644
    - makedirs: true
    - contents: |
        id: {{setting.host}}
        default_include: master.d/*.conf
        worker_threads: 2
        # insecure option
        auto_accept: false

{%if setting.host == 'master' %}

{{setting.kubernetes_svc_file}}:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - contents: |
        [Service]
        Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true"
        Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
        Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
        Environment="KUBELET_DNS_ARGS=--cluster-dns={{setting.cluster_dns}} --cluster-domain=cluster.local --address={{setting.kubelet_address}}"
        Environment="KUBELET_EXTRA_ARGS=--v=4"
        ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_EXTRA_ARGS

{{setting.token_file}}:
  cmd.run:
  # - name: /srv/salt/scripts/kubeadm-init
    - name    : kubeadm init --token {{setting.token}} --pod-network-cidr {{setting.pod_cidr}} --service-cidr {{setting.service_cidr}}
    - user    : root
    - group   : root
    - mode    : 0600
    - template: jinja
    - context :
        {{setting}}
    - env:
        - kubeadm_log        : {{setting.bootstrap_log}}
        - token_file         : {{setting.token_file}}
        - etc_kubernetes     : {{setting.etc_kubernetes}}
        - kubeadm_pillar     : {{setting.kubeadm_pillar}}
        - pod_cidr           : {{setting.pod_cidr}}
        - service_cidr       : {{setting.service_cidr}}
        - advertise_addresses: {{setting.advertise_addresses}}

{{setting.kubernetes_svc_file_drop_in}}:
  file.absent

systemctl daemon-reload:
  cmd.run
systemctl stop kubelet:
  cmd.run
systemctl start kubelet:
  cmd.run


{%if config.kubeadm.kube_num_nodes == 0%}
kubectl taint nodes master dedicated:NoSchedule- :
  cmd.run
{%endif%}

{%endif%}
    
/etc/salt/minion.d/00-minion.conf:
  file.managed:
    - user    : root
    - group   : root
    - mode    : 0644
    - makedirs: true
    - template: jinja
    - contents: |
        id: {{setting.host}}
        master: 
          - {{setting.master}}
        default_include: minion.d/*.conf
        worker_threads: 2

        pillar_roots:
         base:
           - /srv/pillar

# * Problem with dns not in routeable subnet *
# [Service]
# Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true"
# Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
# Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
# --------------------------------------------+
#                                             v
# Environment="KUBELET_DNS_ARGS=--cluster-dns=100.64.0.10 --cluster-domain=cluster.local"
# Environment="KUBELET_EXTRA_ARGS=--v=4"
# ExecStart=
# ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_EXTRA_ARGS
