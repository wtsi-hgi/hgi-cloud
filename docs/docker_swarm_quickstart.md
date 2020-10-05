# Introduction

This document is a quick-start guide to setting up Docker swarm and running some Docker containers on it.

# Creating a new swarm

Make sure you have `terraform 0.11`, and `packer 1.4` installed. Installing `ansible` is also recommended.

1. Clone the `hgi-cloud` repository.

2. Log into the Openstack web interface as `mercury`, using the password stored in `/hgi/secrets/openstack-mercury.pw` on `hgi-farm5` once sudo'd as 'mercury'.

3. Select an appropriate project from the menu in the upper left corner.

4. Download the `openrc.sh` file from Project (top left) > API Access > Download OpenStack RC File > OpenStack RC File

5. Fill in the values at the bottom of `openrc.sh` using `/hgi/secrets/mercury.s3.key` on `hgi-farm5`.

6. Add 'export AWS_S3_ENDPOINT="cog.sanger.ac.uk"' & 'export AWS_DEFAULT_REGION="eu-west-1"' to the bottom of the 'openrc.sh'

7. Run `source openrc.sh`.

8. `cd` to the cloned `hgi-cloud` directory and run `git checkout theta/dockerSwarm`.

9. Run `bash invoke.sh docker create`. This creates a set of Openstack machines which are configured to act as swarm. If 'theta-hgi-prod-subnet-docker-main' has not been setup, run 'bash invoke.sh docker create --networking'

10. To destroy your docker swarm cluster run 'bash invoke.sh docker destroy'

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
