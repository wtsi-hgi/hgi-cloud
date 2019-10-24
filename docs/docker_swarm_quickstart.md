# Introduction

This document is a quick-start guide to setting up Docker swarm and running some Docker containers on it.

# Creating a new swarm

Make sure you have `docker`, `terraform 0.11`, and `packer 1.4` installed. Installing `ansible` is also recommended. 

1. Clone the `hgi-cloud` repository. 

2. Log into the Openstack web interface as `hermes`, using the password stored in `/home/mercury/hermes.openstack.pw` on `hgi-mercury-farm3`.

3. Select an appropriate project from the menu in the upper right corner.

4. Download the `openrc.sh` file from Project (top left) > API Access > Download OpenStack RC File > OpenStack RC File (Identity API v3)

5. Fill in the values at the bottom of `openrc.sh` using `/home/mercury/hermes.s3.key` on `hgi-mercury-farm3`.

6. Run `source openrc.sh`.

7. `cd` to the cloned `hgi-cloud` directory and run `git checkout feature/dockerSwarm`.

8. Run `bash invoke.sh docker create`. This creates a set of Openstack machines which are configured to act as swarm. 

NOTE: If you are installing `terraform 0.11` using Homebrew on OSX, you will need to explicitly add it to the PATH before doing step 8. For example: `export PATH="/usr/local/opt/terraform@0.11/bin:$PATH`

# Adding services to the swarm

1. Create a `docker-compose.yml` file that defines the services that will run on the swarm.

2. Download Hermes' private key from `/home/mercury/ssh-keys/hermes` on `hgi-mercury-farm3`.

`scp mercury@hgi-mercury-farm3:/home/mercury/ssh-keys/hermes .`

3. Go to the Openstack web interface and find the IP address of the manager node.

4. Copy over the compose file and any credentials files your services will need.

`scp -i ./hermes ./config.yml ubuntu@[manager node IP]:~`

`scp -i ./hermes ./docker-compose.yml ubuntu@[manager node IP]:~`, etc

5. (NOTE: Run this step OR step 6) Initialise the swarm using `ansible`:

`ansible all --key-file ./hermes -i 'ubuntu@[manager node IP],' -m docker_stack -a "name=app compose=docker-compose.yml" -vvv`
	
6.  `ssh` into the manager node and start the swarm manually:

`ssh -i ./hermes ubuntu@[manager node IP]:~` 

`docker stack deploy -c docker-compose.yml app`

NOTE: In steps 5 and 6, `app` can be a name of your choosing.

The swarm should now be up and running. Make sure to read the [setup guide](https://github.com/wtsi-hgi/hgi-cloud/blob/feature/dockerSwarm/docs/setup.md) and particularly the [docker swarm runbook](https://github.com/wtsi-hgi/hgi-cloud/blob/feature/dockerSwarm/docs/runbook_docker_swarm.md) for more information.
