{% import_yaml             'config.yml' as config %} 
{% set etc_kubernetes    = '/etc/kubernetes' %}
{% set token_file        = etc_kubernetes+'/token' %}
{% set token             = pillar.kubeadm.token %}

{{token_file}}:
  cmd.run:
  - name: kubeadm join --token {{token}}
