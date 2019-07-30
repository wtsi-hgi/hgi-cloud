# ansible
This is the home of all the ansible roles used within the system.

# Naming and structure
1. All roles anding with `base` suffix, are meant to be for images (either
   containers or instances)
1. All other roles are to be deployed on the running instance, through
   `user_data` script (`cloud.cfg` at later stage)

# vars
It is the directory that contains all the extra varaibles that ansible will
look for during the instance/container provisioning time.

# molecule
It contains the common molecule playbooks and files that any module can refer
to.
