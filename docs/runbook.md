# Getting to the provisioning code
```bash
cd /usr/src/provisioning
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

## Create your cluster
```bash
bash invoke.sh hail create
```

## Scale your cluster
```bash
# TODO: yet to be implemented
bash invoke.sh scale --spark-slaves-count 8
```

## Destroy your cluster
```bash
bash invoke.sh hail destroy
```

## Find the configuration files for your hail cluster and your hail volume

In order to find your configuration files, you need to know the following
details:

1. The current name of the datacenter (i.e. eta)
2. The name of the programme/team that is hosting your cluster (i.e. hgi)
3. The name of the working environment (i.e. dev)
4. Your Openstack's username (i.e. ld14)
5. The name of the deployment (i.e. hail)

There are 2 sets of configuration files. Using a bash-like syntax:

1. For the infrastructure provisioning:
   ```
   ls -la terraform/vars/${DATACENTER}/${PROGRAMME}/${ENV}/${OS_USERNAME}/
   ```
2. For the software provisioning:
   ```
   ls -la ansible/vars/${DATACENTER}/${PROGRAMME}/${ENV}/${OS_USERNAME}/${DEPLOYMENT_NAME}/
   ```

# For Operator of the provisioning system

## Add a user to the provisioning system

## Add an Openstack project to the provisioning system
