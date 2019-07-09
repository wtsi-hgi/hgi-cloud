# How to get ready to use use your cluster
In order to create, destroy or use a Hail cluster, users need to run the
provisioning software distributed in this repository. This software needs
configuration files from the shell environment (each user has to provide their
own), properly compiled property files (already organized and stored in this
repository) and other required software and libraries. In order to make it easy
to distribute / use this software, and to allow it to be used the most flexible
range of scenarios, the team has produced a Docker container (**TODO**: make the
location public).

## Glossary
Please, also consider reading the [Openstack Glossary on the internal SSG Confluence](https://ssg-confluence.internal.sanger.ac.uk/display/OPENSTACK/OpenStack+glossary)
* **Provisioning software**:
  Is the software that is required to create the the cluster. The term
  [provisioning](https://en.wikipedia.org/wiki/Provisioning_\(telecommunications\))
  is used in many different ways and its meaning may slightly change according
  to the context it is used in
  ([server provisioning](https://en.wikipedia.org/wiki/Provisioning_\(telecommunications\)#Server_provisioning),
  [cloud provisioning](https://en.wikipedia.org/wiki/Provisioning_\(telecommunications\)#Self-service_provisioning_for_cloud_computing_services),
  ecc)
* **Docker container**: is a form of
  [OS-level virtualisation](https://en.wikipedia.org/wiki/OS-level_virtualisation)
  whose [purpose is](https://www.docker.com/resources/what-container) to (quote):

  > package up code and all its dependencies so the application runs quickly
  > and reliably from one computing environment to another

* **Console Server**: is the name we decided to give to the server that can run
  the `Provisioning software` the we ship inside a `Docker container` 
* **SSH**
  [Secure Shell](https://en.wikipedia.org/wiki/Secure_Shell): is a tool commonly
  used to execute command or login on remote server. Its security model is based
  on [Asimmetric Cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography)
  and is more effective when used with a set of
  [keys](https://en.wikipedia.org/wiki/Key_\(cryptography\)) spcifically made
  for eac user. SSH is the tool the the user needs to login on the `Console Server`.
* **AWS S3 / Red Hat's Ceph**: are
  [Object Storage](https://en.wikipedia.org/wiki/Object_storage) services.
  Sanger does not actuallt relay on [AWS S3](https://aws.amazon.com/s3/), but
  rather uses an S3 compatible service that runs on top of the
  [Ceph](http://docs.ceph.com/docs/giant/) service in our OpenStack
  infrastructure.

## Preparing the required files
The following are preparatory steps that you are supposed to do just once,
regardles of the scenario in which you want to use the provisioning software,
given that you safely store and keep all your files that you are going to
create.

### Create ssh keys
If you haven't created them yet, you need a pair of `ssh` keys. To
create the keys, you can run the command `ssh-keygen`. `ssh-keygen` is part of
the standard distribution of the `ssh` software. If you can't find it, ask the
Help Desk. Unless you know that you need specific values, just press enter to 
any input. Here is an example output:
``` 
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
`.s3cfg` is the name of the configuration file for a tool called `s3cmd`.
This tool is let's the user manage any aspects of their S3 objects buckets.
`.s3cfg` needs to be located in your home directory on the `Console server` and
it should look like this:
```ini
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

```bash
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
There are some modules of the provisioning software that require more shell
environment variables. Given the values of the `.s3cfg` file, add the following
snippet to the `openrc.sh` file:
```bash
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
```bash
scp -r .ssh .s3cfg openrc.sh ld14@172.27.83.155:
```

### Getting on the Console server
Here follows an example of the simplest way to log in the Console server.
Before typing the command, make sure that the username and the Console server's
IP address are correct.
```bash
ssh ld14@172.27.83.155
```

### Run the container
The provisioning software is shipped inside a Docker container and each user is
supposed to run his/her own container. There are multiple advantages:
* Isolation of the provisioning software from the software installed on the
  Console server.
* Isolation of each user's working session: any number of users can work on the
  same console server without ever interfering with other users, as long as the
  Console server has enough resources. 
* Portability: the same container can be run on the Console server, as well as
  on any other computer on the campus i.e. your laptop.

The command I suggest to run the provisioning container is:
```bash
docker run --tty --interactive --workdir /root --volume ${HOME}:/root hgi/provisioning-base:v0.5 bash
```
The following is a simple explanation of the option that I'm suggesting you to
use:
* `--tty`: Allocates a terminal so you can see what you are typing
* `--interactive`: Creates an interactive session
* `--workdir /root`: Changes the working directory to `root`'s home directory
* `--volume ${HOME}:/root`: Makes the user's current home direcotry available
   inside the container
* `hgi/provisioning-base:v0.5`: This represents the name and version of the
  provisioning container. Keep in mind that `v0.5` reprensents the version of
  the provisioning software and this is subject to change.
* `bash`: This is the name of the shell to run inside the container

### Prepare to run the provisioning software
It's now time to prepare the provisioning software to run:
```bash
source openrc.sh
```