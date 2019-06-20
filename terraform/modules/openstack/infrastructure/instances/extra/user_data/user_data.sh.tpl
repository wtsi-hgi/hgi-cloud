#!/bin/bash -eux

# Log everything in /var/log/user_data.log
exec >> /var/log/user_data.log 2>&1

if [ ! -d "/usr/src/provisioning/ansible" ] ; then
  git clone https://gitlab.internal.sanger.ac.uk/hgi/hgi-systems-cluster-spark.git /usr/src/provisioning
fi

# cp --archive /usr/src/provisioning/ansible /opt/sanger.ac.uk
# rm --recursive /usr/src/provisioning
# cd /opt/sanger.ac.uk/ansible

cd /usr/src/provisioning/ansible
git checkout ${role_version}

# Create the extra vars for the playbook
cat > vars/metadata.yml <<METADATA
---
datacenter: "${datacenter}"
programme: "${programme}"
env: "${env}"
deployment_name: "${deployment_name}"
deployment_owner: "${deployment_owner}"
deployment_color: "${deployment_color}"
role_name: "${role_name}"
role_version: "${role_version}"
count: "${count}"
METADATA

cat > vars/other_data.json <<OTHER
${other_data}
OTHER

# chmod 0600 vault_password.txt

ansible-playbook \
  --extra-vars @vars/${datacenter}.yml \
  --extra-vars @vars/${datacenter}/${programme}.yml \
  --extra-vars @vars/${datacenter}/${programme}/${env}.yml \
  --extra-vars @vars/${datacenter}/${programme}/${env}/${deployment_owner}.yml \
  --extra-vars @vars/${datacenter}/${programme}/${env}/${deployment_owner}/${deployment_name}.yml \
  --extra-vars @vars/${datacenter}/${programme}/${env}/${deployment_owner}/${deployment_name}/${role_name}.yml \
  --extra-vars @vars/metadata.yml \
  --extra-vars @vars/other_data.json \
  instance.yml
