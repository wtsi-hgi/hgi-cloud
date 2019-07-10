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

## Add an Openstack project to the provisioning system
Each new supported openstack project needs a configuration files named
`metadata/${project_name}.rc`. The file has bash syntax and must contain the
following values:

```bash
# The provider of the project
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
mkdir --parents {teraform/vars,ansible/vars}/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}
touch terraform/vars/${META_DATACENTER}.tfvars \
      terraform/vars/${META_DATACENTER}/${META_PROGRAMME}.tfvars \
      terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}.tfvars
touch ansible/vars/${META_DATACENTER}.yml \
      ansible/vars/${META_DATACENTER}/${META_PROGRAMME}.yml \
      ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}.yml
```
## Add a new user to the provisioning system
Each new Hail user requires his/her own configuration files and they need to be syntactically correct:
```bash
touch terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}.tfvars \
      terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail_cluster.tfvars \
      terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail_volume.tfvars

for yml in ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}.yml \
           ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail.yml \
           ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail/hail-slave.yml \
           ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/hail/hail-master.yml do
  test -f ${yml} || echo "---\n{}" > ${yml}
done
```

## Create a new base image

## Promote a base image through the environments

## Test any ansible role
