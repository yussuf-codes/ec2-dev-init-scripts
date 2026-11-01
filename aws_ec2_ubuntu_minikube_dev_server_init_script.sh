#!/bin/bash

EC2_USER="joe"
BASHRC_PATH="/home/${EC2_USER}/.bashrc"
SUDOERS_FILE="/etc/sudoers.d/$EC2_USER"

apt update -y

apt upgrade -y

hostnamectl set-hostname dev-server

useradd "$EC2_USER" -s "/bin/bash" -m

usermod -aG sudo "$EC2_USER"

echo "$EC2_USER ALL=(ALL:ALL) NOPASSWD:ALL" > "$SUDOERS_FILE"

chmod 0440 "$SUDOERS_FILE"

cp -r "/home/ubuntu/.ssh/" "/home/${EC2_USER}/"

chown -R "$EC2_USER:$EC2_USER" "/home/${EC2_USER}/.ssh/"

cp "$BASHRC_PATH" "${BASHRC_PATH}.bak"

chown "$EC2_USER:$EC2_USER" "${BASHRC_PATH}.bak"

cat >> "$BASHRC_PATH" <<'PS1'

PS1='\[\e[92m\][ \u@\h ] - [ \w ] - [ $? ] \$ >\[\e[0m\] '
PS1

apt install -y wget apt-transport-https

curl -fsSL "https://get.docker.com" -o "/root/get-docker.sh"

sh "/root/get-docker.sh"

systemctl enable --now docker

usermod -aG docker "$EC2_USER"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl

mv kubectl "/usr/local/bin/"

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

install minikube-linux-amd64 "/usr/local/bin/minikube"

su - "$EC2_USER" -c "minikube start --driver=docker"
