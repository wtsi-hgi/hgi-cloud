# Introduction

Before you continue reading, there are some terms and values you are
supposed to know. For any term, please read the [Setup Guide](setup.md),
which also contains a short glossary and other useful links.

The following is a list of values / information you need to know. If
unsure, ask to a member of the HGI team.

1. The current name-tag of the datacenter (e.g., `eta`)
2. The name-tag of the programme / team that is hosting your cluster (e.g., `hgi`)
3. The name-tag of the working environment (e.g., `dev`)
4. Your Openstack username (e.g., `ld14`)
5. The name of the deployment (e.g., `hail`)

Using a `bash`-like syntax:

```bash
datacenter="eta"
programme="hgi"
environment="dev"
os_username="ld14"
deployment_name="hail"
```

# For the Operators of the provisioning system
Be aware of the user you run the commands as. Most deployments and images
must be created as `hermes`.

## Add an Openstack project to the provisioning system
Each new supported openstack project needs a configuration files named
`metadata/${project_name}.rc`. The file has bash syntax and must contain the
following values:

```bash
# The cloud provider
META_PROVIDER="openstack"
# The name-tag of the datacenter
META_DATACENTER="eta"
# The name-tag of the programme
META_PROGRAMME="hgi"
# The name-tag of the environment
META_ENV="dev"
```

The following files need to exist and be properly configured (depends on the kind of deployment):
```bash
mkdir --parents {terraform/vars,ansible/vars}/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}

touch terraform/vars/${META_DATACENTER}.tfvars \
      terraform/vars/${META_DATACENTER}/${META_PROGRAMME}.tfvars \
      terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}.tfvars

for yml in ansible/vars/${META_DATACENTER}.yml \
           ansible/vars/${META_DATACENTER}/${META_PROGRAMME}.yml \
           ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}.yml
do
  test -f ${yml} || echo -e "---\n{}" > ${yml}
done
```

## Setting up the networking in an environment
```bash
bash invoke.sh deployment create --name networking
```

## Allow a new user to provision a Hail cluster in a given Openstack project
Each new Hail user requires his/her own configuration files and they need to be syntactically correct:
```bash
mkdir --parents terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME} \
                ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail

touch terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}.tfvars \
      terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail_cluster.tfvars \
      terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail_volume.tfvars

for yml in ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}.yml \
           ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail.yml \
           ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail/hail-slave.yml \
           ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail/hail-master.yml
do
  test -f ${yml} || echo -e "---\n{}" > ${yml}
done
```

## Create a new base image
```bash
bash invoke.sh image create --role-name hail-base --role-version v1.1
```

## Promote (share) a base image
```bash
bash invoke.sh image promote --to hgi-dev --role-name hail-base --role-version v1.1
```

## Create a new docker image
```bash
bash invoke.sh docker_image create --role-name provisioning-base --role-version v0.6
```

## Test any ansible role
The testing framework currently used on for Ansible roles is called
[Molecule](https://molecule.readthedocs.io/en/stable/index.html). Each role
should already be configured.
```bash
cd ansible/role/${role_name}
molecule test
```
