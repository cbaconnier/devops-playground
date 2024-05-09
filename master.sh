#!/bin/bash

set -euxo pipefail

kubeadm config images pull

sudo kubeadm init \
	--pod-network-cidr=10.244.0.0/16 \
	--node-name="$HOSTNAME" \
	--ignore-preflight-errors=all \
	--apiserver-advertise-address=192.168.56.101

# Configure kubeconfig for the master

mkdir -p /home/vagrant/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
sudo chown vagrant:vagrant /home/vagrant/.kube/config

export KUBECONFIG=/home/vagrant/.kube/config

# Configure flannel
# https://github.com/flannel-io/flannel/issues/1098#issuecomment-461706194

curl -LO https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
sed -i.bak 's|        - --ip-masq|        - --ip-masq\n        - --iface=enp0s8|' kube-flannel.yml
kubectl apply -f kube-flannel.yml

# Configure metrics
# https://github.com/kubernetes-sigs/metrics-server/issues/1282

curl -LO https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
sed -i.bak '/--metric-resolution=15s/a \ \ \ \ \ \ \ \ command:\n\ \ \ \ \ \ \ \ - \/metrics-server\n\ \ \ \ \ \ \ \ - --kubelet-insecure-tls\n\ \ \ \ \ \ \ \ - --kubelet-preferred-address-types=InternalIP' components.yaml
kubectl apply -f components.yaml

# start the deamons

sudo ufw allow 6443

sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl enable kubelet

sleep 10

kubectl get pods -A

# Prepare files for the nodes

config_path="/vagrant/tmp"

if [ -d $config_path ]; then
	rm -f $config_path/*
else
	mkdir -p $config_path
fi

cp -i /etc/kubernetes/admin.conf $config_path/config
touch $config_path/join.sh
chmod +x $config_path/join.sh

sudo kubeadm token create --print-join-command >$config_path/join.sh
