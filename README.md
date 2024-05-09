# DevOPS Playground

I'm just learning DevOPS stuff

# Kubernetes on Vagrant Setup

## Instructions

1. Adjust the configuration you want in Vagrantfile
2. Run `vagrant up` to provision the Kubernetes cluster.
3. After setting up the cluster with `vagrant up`, run `./run-on-host-machine.sh` to configure `kubectl` on your host machine.
4. Cleanup the machines with `vagrant destroy kubmaster kubnode1 kubnode2 -f`

## Requirements

- Vagrant
- VirtualBox
- kubectl

## Configure a NFS server

On the host machine

```
sudo pacman -S nfs-utils
sudo echo "#" >> /etc/exports
sudo echo "# Export for Kubernetes" >> /etc/exports
sudo echo "/srv/exports 192.168.56.0/24(rw,sync,no_root_squash)" >> /etc/exports
sudo mkdir /srv/exports
sudo exportfs -rav
sudo systemctl start nfs-server
```

Testing on kubmaster  

```
sudo apt-get install nfs-common

# expected to be empty
df -h | grep /tmp 

sudo mount -t nfs 192.168.56.1:/srv/exports /tmp

# expected to see: 192.168.56.1:/srv/exports.../tmp
df -h | grep /tmp 

# should work and appear on your host folder /srv/exports
sudo touch /tmp/testfile

sudo umount /tmp
```

Notes:

Examples come from Xavki: 
  
  - https://www.youtube.com/watch?v=37VLg7mlHu8&list=PLn6POgpklwWqfzaosSgX2XEKpse5VY2v5&index=1
  - https://gitlab.com/xavki/presentations-kubernetes/-/tree/master
