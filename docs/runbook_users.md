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

* you may want to do this because you have lost / replace your keypair

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

# Using your Hail Cluster

In the following guides, `${ip_address}` is the IP address of your Hail
master node. This can be looked up by examining the configuration files
for the infrastructure provisioning (see above).

**Important**
Any data which you need to process in Hail must be accessible to the
Hail workers. Ideally, you should keep such data (e.g., VCF files, etc.)
in S3. However, you may also put data in Hail's temporary working
directory, which is shared amongst all workers in your Hail cluster. The
path for which is:

    ${HAIL_HOME}/tmp

`${HAIL_HOME}`, as of writing, is `/opt/sanger.ac.uk/hgi/hail`. By
default, this directory is 31GB in size. Note that this is different to
the Jupyter directory, where your Jupyter notebooks will live; this
space (1GB, by default) is only meant for your source code and any data
files placed here won't be accessible to your Hail workers.

See the SSH documentation, below, for instructions on how to get data on
to your cluster, if you can't use S3 for the purpose.

## The Jupyter Notebook Service

Your Jupyter Notebook will be accessible on the internal network at
`http://${ip_address}`, which will redirect you to
`http://${ip_address}/jupyter/tree`. You will be prompted for the
password to allow you to log in.

Note that the underlying Spark service status can be accessed at
`http://${ip_address}/spark/`. This exists largely as a curiosity for
end users, but can be useful to help debugging.

### Restart the Jupyter Notebook Service

In early versions of the provisioned Notebook, there was a "Quit" button
in the upper right corner. If this button was pressed, it would shut
down the Jupyter service on your Hail master node. This button has since
been disabled, but if you are using an older version and have this
button:

1. **Do not press the "Quit" button!**

2. If you do press it, reflect on your life choices and then, to restart
   the Jupyter Notebook service, run the following command:

       ssh ${ip_address} sudo systemctl restart jupyter-notebook.service

   From a machine on which your private key exists, where
   `${ip_address}` is the IP address of your Hail master node.

## SSH to Your Master Node

You can SSH into your master node, to get data on-and-off, if needed, as
well as running non-interactive Hail jobs.

### Shipping Data To-and-From Your Cluster

**Note**
You are advised to store data in S3, rather than embargoing it in the
Hail working temporary directory. Sometimes, however, this is not an
option; for example, if your Hail script needs to save output (e.g., a
plot) and doesn't support writing to S3.

To upload data, available to the Hail cluster for processing:

    scp my_files ${ip_address}:/opt/sanger.ac.uk/hgi/hail/tmp/

To download data from the Hail cluster:

    scp ${ip_address}:/path/to/your/file /destination/path/

For additional documentation, please see the `scp` man-pages.

### Starting a Login Shell on Your Cluster

You have SSH access to your cluster, from which you can launch
non-interactive Hail jobs. The default user on your Hail master node is
`ubuntu`, so you can log in with:

    ssh ubuntu@${ip_address}

Once you've established a session, you will need to change to the `hgi`
user in order to run Hail scripts:

    sudo -iu hgi

#### Running Non-Interactive Hail Jobs

<!-- TODO -->

## Setting-Up S3 Access

<!-- TODO -->
