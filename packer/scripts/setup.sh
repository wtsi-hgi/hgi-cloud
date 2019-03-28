#!/bin/bash -eux

# Install Ansible repository.
apt --assume-yes update && apt --assume-yes upgrade
apt --assume-yes install software-properties-common
apt-add-repository ppa:ansible/ansible

# Install Ansible.
apt --assume-yes update
apt --assume-yes install ansible
mkdir --parents /opt/sanger.ac.uk/ansible/{log,facts.d}
chown --recursive ubuntu:ubuntu /opt/sanger.ac.uk

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic
