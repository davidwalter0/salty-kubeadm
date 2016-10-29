---
*Manage a quick stand up of a stand alone cluster using salt+vagrant+kubeadm*

Currently run from debian / ubuntu with vagrant.

git clone https://github.com/davidwalter0/salty-kubeadm

- run salt/scripts/make-ssh-keys to generate ssh keys for nodes.
- run salt/scripts/token-gen-and-configure to generate tokens and write the config
- run vagrant up

- The current version of kubeadm appears to ignore the service_cidr,
  will be reporting a bug if I don't find this is just a
  misconfiguration.
- The dns pod fails to start with my override of the pod cidr.
- I restart the kubelet with an override in the service file to fix
  the dns ip and the dns then schedules.

The default kubelet service systemd unit file
```
    # cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
    [Service]
    Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true"
    Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
    Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
    Environment="KUBELET_DNS_ARGS=--cluster-dns=100.64.0.10 --cluster-domain=cluster.local"
    Environment="KUBELET_EXTRA_ARGS=--v=4"
    ExecStart=
    ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_EXTRA_ARGS
```

The modified version:
```
    # vagrant ssh -- sudo cat /etc/systemd/system/kubelet.service
    [Service]
    Environment="KUBELET_KUBECONFIG_ARGS=--kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true"
    Environment="KUBELET_SYSTEM_PODS_ARGS=--pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true"
    Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"
    Environment="KUBELET_DNS_ARGS=--cluster-dns=10.3.0.10 --cluster-domain=cluster.local --address=--address=10.1.0.33"
    Environment="KUBELET_EXTRA_ARGS=--v=4"
    ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_SYSTEM_PODS_ARGS $KUBELET_NETWORK_ARGS $KUBELET_DNS_ARGS $KUBELET_EXTRA_ARGS

```

- because systemctl monitors systemd unit files and requires a reload
  3 steps to reload and restart the kubelet
  - daemon-reload
  - stop
  - start

- configure the salt/setting.yml with options to change.

- vagrant up



On my standalone master config, the master standalone node didn't
schedule pods until the taint was removed.

    kubectl taint nodes master dedicated:NoSchedule-

Afterward the gist with a simple pod image does schedule

    kubectl create -f https://gist.githubusercontent.com/davidwalter0/99d335ae6f44e465704d0717d0db6f61/raw/16dda706ebd56064824cdcb09485ad85a097b214/-

