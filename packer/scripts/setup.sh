#!/bin/bash -eux

# Install Ansible repository.
apt-get --assume-yes update && apt-get --assume-yes upgrade
apt-get --assume-yes install software-properties-common
apt-add-repository --yes ppa:ansible/ansible

# Install Ansible.
apt-get --assume-yes update
apt-get --assume-yes install ansible
mkdir --parents /opt/sanger.ac.uk/ansible/{log,facts.d}
chown --recursive ubuntu:ubuntu /opt/sanger.ac.uk

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic
