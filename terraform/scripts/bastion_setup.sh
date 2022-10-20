#!/bin/bash

# add new bastion user
useradd --shell /usr/sbin/nologin ${BASTION_USER}

# update apt
apt update && apt upgrade
apt remove snapd

# copy ssh key from root user
mkdir /home/${BASTION_USER}/.ssh
cp /root/.ssh/authorized_keys /home/${BASTION_USER}/.ssh/authorized_keys

# comment out SSH options that need to be configured and already exist in the config file
sed -i '
s/^PasswordAuthentication/#\0/g
s/^PermitRootLogin/#\0/g
s/^AllowUsers/#\0/g
s/^AuthenticationMethods/#\0/g
s/^ForceCommand/#\0/g
s/^PermitTTY/#\0/g
s/^X11Forwarding/#\0/g
s/^PermitTunnel/#\0/g
s/^GatewayPorts/#\0/g
s/^AllowAgentForwarding/#\0/g
s/^AllowStreamLocalForwarding/#\0/g
' /etc/ssh/sshd_config

# append required SSH options
cat >> /etc/ssh/sshd_config <<- EOF
PasswordAuthentication no
PermitRootLogin no
AllowUsers ${BASTION_USER}
AuthenticationMethods publickey
ForceCommand /usr/sbin/nologin
PermitTTY no
X11Forwarding no
PermitTunnel no
GatewayPorts no
AllowAgentForwarding no
AllowStreamLocalForwarding no
EOF
