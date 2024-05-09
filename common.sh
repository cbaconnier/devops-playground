#!/bin/bash

set -euxo pipefail

# Disable the swap

sudo swapoff -a
sudo sed -i '/ swap/d' /etc/fstab

# Load the kernel modules

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set the kernel parameters

sudo tee /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Installing docker

curl -sSL https://get.docker.com/ | sh

# Installing containerd and kubernetes

export DEBIAN_FRONTEND=noninteractive

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg bash-completion

sudo mkdir -p /etc/containerd/
sudo chown vagrant:vagrant /etc/containerd
sudo containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# Installing kubelet, kubeadm, and kubectl
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Bash completion
echo "source <(kubectl completion bash)" >>/home/vagrant/.bashrc
