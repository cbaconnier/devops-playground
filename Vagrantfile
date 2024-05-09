# -*- mode: ruby -*-
# vi: set ft=ruby :

BASE_BOX_IMAGE = "ubuntu/jammy64" # ubuntu 22
CPUS_MASTER = 1
MEMORY_MASTER = 1024
CPUS_WORKER = 2
MEMORY_WORKER = 2048

# Change to increase the number of workers
WORKER_NODE_COUNT = 2

Vagrant.configure("2") do |config|

  config.vm.provision "shell", inline: <<-SHELL
        export WORKER_NODE_COUNT=#{WORKER_NODE_COUNT}

        echo "192.168.56.101 kubmaster kubmaster" >> /etc/hosts

        for ((i=1; i<=$WORKER_NODE_COUNT; i++)); do
          echo "192.168.56.$((110 + $i)) kubnode$i kubnode$i" >> /etc/hosts
        done
    SHELL

  config.vm.define "kubmaster" do |master|
    master.vm.provision "shell", path: "common.sh"

    master.vm.box = BASE_BOX_IMAGE
    master.vm.hostname = 'kubmaster'
    master.vm.network :private_network, ip: "192.168.56.101"

    master.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      v.customize ["modifyvm", :id, "--memory", MEMORY_MASTER]
      v.customize ["modifyvm", :id, "--name", "kubmaster"]
      v.customize ["modifyvm", :id, "--cpus", CPUS_MASTER]
    end

    master.vm.provision "shell", path: "master.sh"
  end


  # Worker nodes
  (1..WORKER_NODE_COUNT).each do |i|
    config.vm.define "kubnode#{i}" do |worker|

      worker.vm.provision "shell", path: "common.sh"

      worker.vm.box = BASE_BOX_IMAGE
      worker.vm.hostname = "kubnode#{i}"
      worker.vm.network :private_network, ip: "192.168.56.#{110 + i}"

      worker.vm.provider :virtualbox do |v|
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.customize ["modifyvm", :id, "--memory", MEMORY_WORKER]
        v.customize ["modifyvm", :id, "--name", "kubnode#{i}"]
        v.customize ["modifyvm", :id, "--cpus", CPUS_WORKER]
      end
      worker.vm.provision "shell", path: "node.sh"
    end
  end
end

