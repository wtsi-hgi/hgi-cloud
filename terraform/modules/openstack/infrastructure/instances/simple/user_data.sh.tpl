#!/bin/bash -eux

# Log everything in /var/log/user_data.log
exec >> /var/log/user_data.log 2>&1

cd /opt/sanger.ac.uk/ansible

# Create the extra vars for the playbook
cat > vars.yml <<VARS
---
datacentre: "${datacentre}"
os_release: "${os_release}"
programme: "${programme}"
env: "${env}"
deployment_name: "${deployment_name}"
deployment_version: "${deployment_version}"
deployment_color: "${deployment_color}"
role_name: "${role_name}"
role_version: "${role_version}"
count: "${count}"
VARS

ansible-playbook instance.yml --extra-vars @vars.yml
