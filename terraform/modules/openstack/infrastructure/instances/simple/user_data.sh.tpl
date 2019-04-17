#!/bin/bash -eux

# Log everything in /var/log/user_data.log
exec >> /var/log/user_data.log 2>&1

git clone https://gitlab.internal.sanger.ac.uk/hgi/hgi-systems-cluster-spark.git /usr/src/provisioning
cp --archive /usr/src/provisioning/ansible /opt/sanger.ac.uk
rm --recursive /usr/src/provisioning

cd /opt/sanger.ac.uk/ansible

# Create the extra vars for the playbook
cat > metadata.yml <<VARS
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

# Created the default password file for ansible-vault
# This should be replaced by Openstack's barbican:
# https://docs.openstack.org/security-guide/secrets-management.html
cat > vault_password.txt <<VAULT
${vault_password}
VAULT
chmod 0600 vault_password.txt

ansible-playbook instance.yml \
  --vault-id vault_password.txt \
  --extra-vars @metadata.yml \
  --extra-vars @vars/${os_release}-${programme}-${env}.yml
