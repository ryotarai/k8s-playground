#!/bin/bash
set -ex

apt update
apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

add-apt-repository \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt update
apt install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}') kubelet kubeadm kubectl

kubeadm init

VAGRANT_HOME=/home/vagrant
mkdir -p $VAGRANT_HOME/.kube
cp -i /etc/kubernetes/admin.conf $VAGRANT_HOME/.kube/config
chown -R vagrant:vagrant $VAGRANT_HOME/.kube

ROOT_HOME=/root
mkdir -p $ROOT_HOME/.kube
cp -i /etc/kubernetes/admin.conf $ROOT_HOME/.kube/config
chown -R root:root $ROOT_HOME/.kube

kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
