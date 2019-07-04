# How to get ready to use use your cluster

## Preparing the required files
The following are preparatory steps that you are supposed to do just once, given
that you safely store and keep all your files.

### Create ssh keys
In order to create / destroy your cluster, you need a pair of `ssh` keys. To
create the keys, you can run the command `ssh-keygen`. `ssh-keygen` is part of
the standard distribution of the `ssh` software. If you can't find it, ask the Help Desk.
Unless you know that you need specific values, just press enter to any input.
```
$ ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/home/ld14/.ssh/id_rsa): 
Created directory '/home/ld14/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/ld14/.ssh/id_rsa.
Your public key has been saved in /home/ld14/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:Yuy/kpyOsFm4cJcpxut6mvMmwaK+a3214NcDZ8ryu/A ld14@console-v0-5
The key's randomart image is:
+---[RSA 2048]----+
|                 |
|                 |
|                 |
|     .           |
|.     + S        |
|oo . * + o       |
|+.O *o=oB        |
|+*o@ =B* o       |
|*&X o.=E=..      |
+----[SHA256]-----+
```

### Copy / Create .s3cfg file
`.s3cfg` is the name of the configuration file for a command called `s3cmd`.
This command is going to be used internally by the provisioning software, and
it needs to be configured. `.s3cfg` needs to be located in your home directory.
It should look like this:
```
[default]
encrypt = False
host_base = cog.sanger.ac.uk
host_bucket = %(bucket)s.cog.sanger.ac.uk
progress_meter = True
use_https = True
access_key = ...
secret_key = ...
```
`access_key` and `secret_key` values are very important and also sensitive
information, and therfore they have been omitted.

### Download / Create the openrc.sh file of the hgi project
`openrc.sh` files contains a list of environment variables that are going to be
used throughout the provisioning software.

```
#!/usr/bin/env bash
# To use an OpenStack cloud you need to authenticate against the Identity
# service named keystone, which returns a **Token** and **Service Catalog**.
# The catalog contains the endpoints for all services the user/tenant has
# access to - such as Compute, Image Service, Identity, Object Storage, Block
# Storage, and Networking (code-named nova, glance, keystone, swift,
# cinder, and neutron).
#
# *NOTE*: Using the 3 *Identity API* does not necessarily mean any other
# OpenStack API is version 3. For example, your cloud provider may implement
# Image API v1.1, Block Storage API v2, and Compute API v2.0. OS_AUTH_URL is
# only for the Identity API served through keystone.
export OS_AUTH_URL=https://eta.internal.sanger.ac.uk:13000/v3
# With the addition of Keystone we have standardized on the term **project**
# as the entity that owns the resources.
export OS_PROJECT_ID=f1c35e83bca7412f847211257c73b5f4
export OS_PROJECT_NAME="hgi-ci"
export OS_USER_DOMAIN_NAME="Default"
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
export OS_PROJECT_DOMAIN_ID="default"
if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi
# unset v2.0 items in case set
unset OS_TENANT_ID
unset OS_TENANT_NAME
# In addition to the owning entity (tenant), OpenStack stores the entity
# performing the action as the **user**.
export OS_USERNAME="ld14"
# With Keystone you pass the keystone password.
echo "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: "
read -sr OS_PASSWORD_INPUT
export OS_PASSWORD=$OS_PASSWORD_INPUT
# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="regionOne"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3
```

### Add AWS environment variables to opnerc.sh
There are some modules of the provisioning software that require other
environment variables. Given the values of the `.s3cfg` file, add the following
snippet to the `openrc.sh` file:
```
# Fixed value that represnts the name of the internal S3 service
export AWS_S3_ENDPOINT="cog.sanger.ac.uk"
# Fixed value for something that does not apply to our Openstack, but will be
# used to satisfy the requirements of some services
export AWS_DEFAULT_REGION="eu-west-1"
# Please fill in the value you'll find for access_key in .s3cfg file
export AWS_ACCESS_KEY_ID="..."
# Please fill in the value you'll find for secret_key in .s3cfg file
export AWS_SECRET_ACCESS_KEY="..."
```

## Setting up your home on the Console server
The Console is the server that has the provisioning container installed and
will let you create and destroy your clusters. Since there is no way to persist
or import your home directories from the farm (at the time this document has
been written), the follwing stesp are meant to be performed each time we have
create a new Console server (for instance, a new version of the provisioning
software has been released).

### Copy ssh keys, .s3cfg and openrc.sh file to the Console server
Here follows an example of the simplest way to copy your files over. Before
typing the command, make sure that the username and the Console server's IP
address are correct.
```
scp -r .ssh .s3cfg openrc.sh ld14@172.27.83.155:
```

### Getting on the Console server
Here follows an example of the simplest way to log in the Console server.
Before typing the command, make sure that the username and the Console server's
IP address are correct.
```
ssh ld14@172.27.83.155
```

7) Run the container:
	# --tty							# Allocate a terminal so you can see what you are typing
	# --interactive	 					# Create an interactive session
	# --workdir /root					# change working directory to software location
	# --volume /var/run/docker.sock:/var/run/docker.sock	# Use the docker daemon socket of the host
	# --volume ${HOME}:/root				# Make the user's home available in the container
	# hgi/provisioning-base:0.0.3				# Name and version of the image to use
	# bash							# Shell to run inside the container

	$ docker run --tty --interactive --workdir /root --volume /var/run/docker.sock:/var/run/docker.sock --volume ${HOME}:/root hgi/provisioning-base:v0.5 bash

8) Load the openrc.sh file:
	$ source openrc.sh
9) Setup the user:
	$ bash invoke.sh user create --public-key=~/.ssh/id_rsa.pub
10) Create the hail cluster:
	$ bash invoke.sh hail create
11) Login on Jupyter
	# HOWTO
