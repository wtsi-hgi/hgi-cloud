#!/bin/bash -ex

# mkdir --parents /opt/sanger.ac.uk/hgi
# chown ubuntu.ubuntu /opt/sanger.ac.uk/hgi
# chmod 0755 /opt/sanger.ac.uk/hgi
# 
# usermod  --login hgi ubuntu
# groupmod --new-name hgi ubuntu
# usermod  --home /opt/sanger.ac.uk/hgi --move-home hgi
# 
# if [ -f /etc/sudoers.d/90-cloudimg-ubuntu ]; then
#   mv /etc/sudoers.d/90-cloudimg-ubuntu /etc/sudoers.d/90-cloud-init-users
# fi
# sed --in-place --expression "s/ubuntu/hgi/g" /etc/sudoers.d/90-cloud-init-users
