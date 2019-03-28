#!/bin/bash -eux

# Log everything in /var/log/user_data.log
exec >> /var/log/user_data.log 2>&1

# Create the facts for this role
cat > /opt/sanger.ac.uk/ansible/facts.d/${var.role}.fact <<FACTS
${jsonencode(var.facts)}
FACTS

cd /opt/sanger.ac.uk/ansible

ansible-playbook playbooks/${var.role}.yml
