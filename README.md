---
*Manage a quick stand up of a stand alone cluster using salt+vagrant+kubeadm*

Currently run from debian / ubuntu with vagrant + virtualbox + ubuntu/xenial + kubeadm.

git clone https://github.com/davidwalter0/salty-kubeadm

- configure a natnetwork. salt/settings.yml option master ip and node
  ips will use this for their bridge.
  - retain the virtualbox nat network on the primary interface
  - in the version of the xenial box the network devices use the new
    interface name, you may have to adjust if your setup is different
  - if you want to run multiple of these standalone masters on a host,
    the ip in this config will have to be managed to match the ip in
    salt/settings.yml

```
    master.vm.provision "shell",
                        run: "always",
                        inline: "ifconfig enp0s8 10.1.0.33 netmask 255.255.255.0 up"
```

- run salt/scripts/make-ssh-keys to generate ssh keys for nodes.
- run salt/scripts/token-gen-and-configure to generate tokens and write the config
- run vagrant up

- The current version of kubeadm appears to ignore the service_cidr,
  will be reporting a bug if I don't find this is just a
  misconfiguration.
- The dns pod fails to start with my override of the pod cidr.
- I restart the kubelet with an override in the service file to fix
  the dns ip and the dns then schedules.

The default kubelet service systemd unit file is setting cluster domain to a non service domain address

    vagrant ssh -- sudo systemctl cat -l kubelet
    ...
    KUBELET_DNS_ARGS=--cluster-dns=100.64.0.10


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

