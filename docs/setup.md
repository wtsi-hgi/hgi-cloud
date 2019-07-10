# Introduction

This is the documentation for bringing up a Hail cluster, intended for
end-users. Before you continue reading, there are some terms and values
that you need to know.

## Glossary

Please, also consider reading the [Openstack
Glossary](https://ssg-confluence.internal.sanger.ac.uk/display/OPENSTACK/OpenStack+glossary)
on the internal SSG Confluence.

* **Provisioning Software**
  is the software that is required to create the cluster. The term
  [provisioning](https://en.wikipedia.org/wiki/Provisioning_\(telecommunications\))
  is used in many different ways and its meaning may slightly change
  according to the context it is used in
  (e.g., [server provisioning](https://en.wikipedia.org/wiki/Provisioning_\(telecommunications\)#Server_provisioning),
  [cloud provisioning](https://en.wikipedia.org/wiki/Provisioning_\(telecommunications\)#Self-service_provisioning_for_cloud_computing_services),
  etc.)

* **Docker Containerisation**
  is a form of [OS-level virtualisation](https://en.wikipedia.org/wiki/OS-level_virtualisation)
  whose [purpose](https://www.docker.com/resources/what-container) is,
  to quote:

  > [P]ackage up code and all its dependencies so the application runs
  > quickly and reliably from one computing environment to another

* **Console Server** is the name we have given to the server that can
  run the *provisioning software* which we ship inside a *Docker
  container*.

* **SSH ([Secure Shell](https://en.wikipedia.org/wiki/Secure_Shell))**
  is a tool commonly used to execute commands or login to a remote
  server. Its security model is based on [asymmetric cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography)
  and is most effective when used with a set of [keys](https://en.wikipedia.org/wiki/Key_\(cryptography\))
  specifically made to identify each user. SSH is the tool the user
  needs to login to the *Console Server*.

* **AWS S3 / Red Hat's Ceph**
  are [object storage](https://en.wikipedia.org/wiki/Object_storage)
  services. Sanger does not actually use [AWS S3](https://aws.amazon.com/s3/),
  but rather uses an S3-compatible service that runs on top of the
  [Ceph](http://docs.ceph.com/docs/giant/) service in our OpenStack
  infrastructure.

## Required Information

The following is a list of values / information you will need to know to
continue. If unsure, ask to a member of the HGI team. Some of these
values are subject to change, and may be different from the ones used in
the examples below.

1. Your Openstack username: This will typically match your normal
   network password (e.g., `ld14`).

2. Your Openstack password: This will not match your normal network
   password at first, but can be changed manually later. To obtain or
   reset this password, you can follow the [documentation provided by
   SSG](https://ssg-confluence.internal.sanger.ac.uk/display/OPENSTACK/FAQ#FAQ-HowdoIgetorresetmypassword?).

3. Your common (LDAP) password: This *is* your normal network password.

4. The Fully Qualified Domain Name or IP address of the Console Server
   (e.g., `172.27.83.155`)

5. The version of the provisioning software (e.g., `v0.5`)

# Running the Provisioning Software

In order to create, destroy or use a Hail cluster, users need to run the
provisioning software distributed in this repository. This software
needs configuration files from the shell environment (each user has to
provide their own), properly compiled property files (already organised
and stored in this repository) and other required software and
libraries. In order to make it easy to distribute / use this software,
and to allow it to be used in the most flexible range of scenarios, the
team has produced a Docker container, which is run from the Console
Server.

<!-- TODO Make the Docker container public, so it can be run outside the
context of the console server -->

## Preparing the Required Files

The following preparatory steps are required, just once, regardless of
the scenario in which you want to use the provisioning software, given
that you safely store and keep all your files that you are going to
create.

### Create SSH Keys

Your SSH keys ought to be in your home directory, in a directory named
`.ssh`; the private key is named `id_rsa`, and public key `id_rsa.pub`.
If you don't have these, you will need to create a pair of keys.

To create the keys, you can run the command `ssh-keygen`. `ssh-keygen`
is part of the standard distribution of the `ssh` software. If you can't
find it, ask the Help Desk. Unless you know that you need specific
values, just press enter to any input. Here is an example output:

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

### Copy / Create Your S3 Configuration

`.s3cfg` is the name of the configuration file for a tool called
`s3cmd`. This tool let's the user manage any aspect of their S3 objects
and buckets. `.s3cfg` needs to be located in your home directory on the
`Console server` and it should look like this:

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

The values for `access_key` and `secret_key` are very important and also
sensitive information, so have therefore been omitted here.

### Download / Create the `openrc.sh` File of the HGI Project

The `openrc.sh` file contains a list of environment variables that are
going to be used throughout the provisioning software.

For example:

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

This file can be downloaded from the Openstack web frontend (Horizon)
for your user and project. [Documentation](https://ssg-confluence.internal.sanger.ac.uk/display/OPENSTACK/FAQ#FAQ-Whydoesn'tmyAPIfilework?I'mabletologintotheHorizonwebinterface.)
for which is available from SSG. *It is important that you use the
**v3** RC file.*

### Add AWS (S3) Environment Variables to `openrc.sh`

There are some modules of the provisioning software that require more
shell environment variables. Given the values of the `.s3cfg` file, add
the following snippet to the end of the `openrc.sh` file from the
previous step:

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

## Setting up Your Home on the Console Server

The Console is the server that has the provisioning container installed
and will let you create and destroy your clusters. Since there is no way
to persist or import your home directories from the farm (at the time
this document has been written), the following steps are meant to be
performed each time a new Console Server is created by HGI (e.g., when a
new version of the provisioning software has been released).

### Copy SSH Keys, `.s3cfg` and `openrc.sh` File to the Console Server

Herein follows an example of the simplest way to copy your files over.
Before typing the command, make sure that the username and the Console
Server's IP address are correct.

```bash
scp -r ~/.ssh ~/.s3cfg openrc.sh ld14@172.27.83.155:
```

This assumes that the `openrc.sh` file is in your current working
directory. You may change these values as needed (e.g., if you want to
use a different key pair, etc.)

### Getting on the Console server

Herein follows an example of the simplest way to login to the Console
Server.  Before typing the command, make sure that the username and the
Console Server's IP address are correct.

```bash
ssh ld14@172.27.83.155
```

### Run the Container

The provisioning software is shipped inside a Docker container and each
user is supposed to run his/her own container. This has multiple
advantages:

* Isolation of the provisioning software from the software installed on
  the Console server.

* Isolation of each user's working session: any number of users can work
  on the same Console Server without ever interfering with other users,
  as long as the Console Server has enough resources.

* Portability: the same container can be run on the Console Server, as
  well as on any other computer on the campus (e.g., your laptop).

The command we suggest to run the provisioning container is:

```bash
docker run --tty --interactive --workdir /root --volume ${HOME}:/root hgi/provisioning-base:v0.5 bash
```

The following is a simple explanation of the suggested options:

* `--tty`: Allocates a terminal so you can see what you are typing
* `--interactive`: Creates an interactive session
* `--workdir /root`: Changes the working directory to `root`'s home
  directory
* `--volume ${HOME}:/root`: Makes the user's current home directory
  available inside the container
* `hgi/provisioning-base:v0.5`: This represents the name and version of
  the provisioning container. Keep in mind that `v0.5` represents the
  version of the provisioning software and this is subject to change.
* `bash`: This is the name of the shell to run inside the container

### Prepare to Run the Provisioning Software

It's now time to prepare the provisioning software to run:

```bash
source openrc.sh
cd /usr/src/provisioning
git pull
```

Once this step is complete, we can now provision the Hail cluster. To do
this, please follow the appropriate guide in the Runbooks:

* [Runbooks for Users](runbook_users.md)
* [Runbooks for Operators](runbook_ops.md)
