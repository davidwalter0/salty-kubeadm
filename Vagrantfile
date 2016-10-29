# -*- mode: ruby -*-
# vi: set ft=ruby :

def config_natnetwork(config,ip)
  config.vm.provider "virtualbox" do |v|
    v.customize ["natnetwork", "modify", "--netname", "kubenat", "--network", ip, "--dhcp", "on"]
  end
end

# Tried several variants with mixed success, but vagrant appears to
# assume the default nat has been configured, if not fails to
# connect.
def nat(config, net)
  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--nic2", "natnetwork",
                 "--nat-network2", "kubenat", "--cableconnected2", "on",
                 "--nictype2", "virtio",
                 "--nicpromisc2", "allow-all",
                 "--natnet2", net]
  end
end

# salt/scripts/config.sh sets KUBE_NUM_NODES and sets up
# salt/config.yml

VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config_natnetwork(config, "10.1.0.0/24")
  num_nodes = (ENV['KUBE_NUM_NODES'] || 0).to_i

  config.vm.define "master" do |master|
    config.vm.provider "virtualbox" do |vbox, override|
      vbox.memory = 2048
      vbox.cpus = 4
      vbox.customize ["modifyvm", :id, "--ioapic", "on"]
    end
    nat(config,"10.1.0.33")
    master.vm.provision "shell",
                        run: "always",
                        inline: "ifconfig enp0s8 10.1.0.33 netmask 255.255.255.0 up"

    master.vm.synced_folder "salt/", "/srv/salt/"
    master.vm.provision :salt do |salt|
      if num_nodes == 0
        salt.masterless     = true
        master.vm.hostname  = 'master'
        salt.minion_config  = "salt/minion/minion.sls"
      else
        master.vm.hostname  = "master"
        salt.install_master = true
        salt.master_config  = "salt/master/master.sls"
        salt.master_key     = "salt/keys/id_rsa_master.pem"
        salt.master_pub     = "salt/keys/id_rsa_master.pub"
        salt.minion_key     = "salt/keys/id_rsa_master.pem"
        salt.minion_pub     = "salt/keys/id_rsa_master.pub"
        salt.seed_master    = {
                                "node1" => "salt/keys/id_rsa_node1.pub",
                                "node2" => "salt/keys/id_rsa_node2.pub"
                              }
        end
        salt.run_highstate = true
        # salt.log_level     = 'debug'
        salt.verbose       = false
    end
  end

  ## For masterless, mount your salt file root
  num_nodes.times do |n|
    node_index    = n+1
    config.vm.provider "virtualbox" do |vbox, override|
      vbox.memory = 1024
      vbox.cpus   = 1
    end
    config.vm.define "node#{node_index}" do |node|
      node.vm.hostname = "node#{node_index}"
      nat(config,"10.1.0.#{33 + node_index}/24")
      node.vm.provision "shell",
                        run: "always",
                        inline: "ifconfig enp0s8 10.1.0.#{33+node_index} netmask 255.255.255.0 up"
      config.vm.synced_folder "salt/", "/srv/salt/"
      config.vm.provision :salt do |salt|
        salt.minion_config = "salt/minion/minion.sls"
        salt.minion_key    = "salt/keys/id_rsa_node#{node_index}.pem"
        salt.minion_pub    = "salt/keys/id_rsa_node#{node_index}.pub"
        # salt.log_level     = 'debug'
        salt.verbose       = false
        salt.run_highstate = true
      end
    end
  end
end
