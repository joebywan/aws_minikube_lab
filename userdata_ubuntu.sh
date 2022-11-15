#!/bin/bash -x

# Set environment variables required to get this working
# These aren't exported normally until the system is setup,
# hence doing it here instead.
echo "export PATH=$PATH:/usr/local/bin" >> ~/.bash_profile && \
echo "export GOCACHE=/root/go/cache" >> ~/.bash_profile && \
echo "export HOME=/root" >> ~/.bash_profile && \
source ~/.bash_profile

mkdir -p /root/go/cache

# Update the OS
apt-get update

# Install dependencies
apt-get install -y \
ca-certificates \
curl \
gnupg \
lsb-release \
golang-go \
conntrack

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl 
chmod +x ./kubectl 
mv ./kubectl /usr/local/bin/kubectl

# Install docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-compose-plugin
chmod 666 /var/run/docker.sock # Need this to allow minikube to run properly

# Install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && mv minikube /usr/local/bin/

# Setup service file for minikube
cat >/etc/systemd/system/minikube.service <<EOL
[Unit]
Description=minikube
After=docker.service docker.socket

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ssm-user/
ExecStart=/usr/local/bin/minikube start
ExecStop=/usr/local/bin/minikube stop
User=ssm-user
Group=ssm-user

[Install]
WantedBy=multi-user.target
EOL


# Install cri-ctl (minikube dependency)
VERSION="v1.25.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
cp /usr/local/bin/crictl /usr/sbin/ # Hacky fix to get minikube to see crictl
rm -f crictl-$VERSION-linux-amd64.tar.gz

# Instructions for installing cri-dockerd: https://github.com/Mirantis/cri-dockerd#build-and-install
# Install cri-dockerd
cd /tmp
git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd -buildvcs=false
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
sed -i '/ExecStart/s/$/ --network-plugin=${plugin}/' ./packaging/systemd/cri-docker.service
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service


# must add the network cni thing to the cri-dockerd service

# Reload systemctl then start the services.  Might need a sleep before minikube?
systemctl daemon-reload && \
systemctl enable cri-docker.service && \
systemctl enable --now cri-docker.socket
systemctl enable minikube && \
systemctl start minikube