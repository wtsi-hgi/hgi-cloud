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

# For Users of the provisioning system

## Set yourself up in the provisioning system
```bash
bash invoke.sh user create
```

## Update your SSH keys in the provisioning system
```bash
bash invoke.sh user destroy
bash invoke.sh user create
```

## Remove yourself from the provisioning system
```bash
bash invoke.sh user destroy --yes-also-the-bucket
```

## Create your Hail cluster
```bash
bash invoke.sh hail create
```

## Scale your Hail cluster
```bash
# TODO: yet to be implemented
bash invoke.sh hail scale --spark-slaves-count 8
```

## Destroy your Hail cluster
```bash
bash invoke.sh hail destroy
```

## Find the configuration files for your hail cluster and your hail volume

There are 2 sets of configuration files:
1. For the infrastructure provisioning:
   ```
   ls -la terraform/vars/${datacenter}/${programme}/${environment}/${os_username}/
   ```
2. For the software provisioning:
   ```
   ls -la ansible/vars/${datacenter}/${programme}/${environment}/${os_username}/${deployment_name}/
   ```
