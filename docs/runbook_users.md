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

### SSH Configuration

To avoid remembering `${ip_addess}`, you can create an SSH configuration
using a more memorable name. For example, in your `~/.ssh/config` file,
replacing `${ip_address}` appropriately in the following:

```ssh
Host hail
  Hostname ${ip_addess}
  User ubuntu
```

Will allow you to access your cluster's master node, either as a login
shell or copying data, using the name `hail` instead of
`ubuntu@${ip_address}`.

#### Running the Spark Shell

The Spark shell can be used to run non-interactive Hail scripts (e.g.,
those which aren't exploratory in nature and potentially require a long
run time) as well as a REPL ([*r*ead-*e*valuate-*p*rint *l*oop](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop)),
not conceptually dissimilar to a Jupyter notebook.

If you need S3 access, you should first configure your environment (see
below). Otherwise, to start a REPL, run:

    pyspark

You can then initiate an interactive Hail session using the following
code:

```python
import os
import hail

tmp_dir = os.path.join(os.environ["HAIL_HOME"], "tmp")
hail.init(sc=sc, tmp_dir=tmp_dir)
```

Alternatively, to run a non-interactive script, it can be submitted
using:

    spark-submit /path/to/your/script.py

The "boilerplate" for non-interactive scripts is slightly different than
the code run in the REPL, because you need to acquire a Spark Context
(the REPL provides this for you automatically). The code should change
to:

```python
import os
import pyspark
import hail

sc = pyspark.SparkContext()
tmp_dir = os.path.join(os.environ["HAIL_HOME"], "tmp")
hail.init(sc=sc, tmp_dir=tmp_dir)
```

This is the same boilerplate that you would use in a Jupyter session.

## Setting-Up S3 Access

### In a Jupyter Notebook

To get your S3 credentials into your Jupyter Notebook, you need to add
the following commands after acquiring the Spark Context and before
initialising Hail:

```python
import os
import pyspark
import hail

sc = pyspark.SparkContext()
tmp_dir = os.path.join(os.environ["HAIL_HOME"], "tmp")

## This bit is for configuring S3 access:
hadoop_config = sc._jsc.hadoopConfiguration()
hadoop_config.set("fs.s3a.access.key", "XXX")  # Replace XXX with your AWS Access Key
hadoop_config.set("fs.s3a.secret.key", "YYY")  # Replace YYY with your AWS Secret Key

hail.init(sc=sc, tmp_dir=tmp_dir)
```

The `XXX` and `YYY` in the above need to be replaced with your AWS
access key and secret key, respectively. These can be found in you
`.s3cfg` file.

**Important**
If you are using source control (e.g., Git), take care not to check in
secrets such as your AWS keys. If you accidentally push these to, say,
GitHub, the whole world now has access to your S3 credentials. Ideally
these should be kept in a separate configuration file, which is not
checked in, and loaded in to your Jupyter Notebook. HGI can assist with
setting this up.

### In a Spark Shell

When running a script using `pyspark` or `spark-submit`, you do not have
to explicitly set the AWS keys within your script. Instead, these are
determined by Spark from the environment. To this end, you must set the
appropriate environment variables before running your script:

```bash
export AWS_ACCESS_KEY_ID="XXX"
export AWS_SECRET_ACCESS_KEY="YYY"
```

The `XXX` and `YYY` in the above need to be replaced with your AWS
access key and secret key, respectively. These can be found in you
`.s3cfg` file.

**Tip**
The environment variables only need to be set once per session and, to
avoid the session terminating prematurely, you can do this within a
`tmux` or `screen` session. You can then log back in to your master
node, with its working state preserved.

## Collective Wisdom on S3 Usage

* Do not use underscores in your bucket names, they are not supported by
  Spark's S3 driver and using them will give you misleading errors.

* Do not include colons or other special characters in your object
  names. To be safe, limit yourself to alphanumeric characters, full
  stops (`.`), dashes (`-`) and underscores (`_`).

* When reading and writing S3, using Hail, you must use the URL scheme
  `s3a://`, rather than `s3://`. So, say you have a file named
  `chr10.vcf.gz` in a bucket called `my-project`, then its address
  (inasmuch as Hail can understand) would be
  `s3a://my-project/chr10.vcf.gz`.
