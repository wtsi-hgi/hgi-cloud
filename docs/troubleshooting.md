# Logging

When in doubt, always check the log files!

* Provisioning: During the start-up phase of your cluster, logs are
  written to `/var/log/user_data.log`.

* Spark: Spark's runtime logs are written to [<!-- TODO -->]. Also, the
  current status of your Spark cluster can be found using its web
  interface at `http://${ip_address}/spark/`.

* Hail: Hail's runtime logs are, by default, written to the current
  working directory, in a file starting `hail-` followed by the date and
  start time. This can be overridden in the `hail.init` function.

# Troubleshooting

## The Cluster Won't Start

Check the provisioning logs. It can take a few minutes, when you first
build your cluster, for each node to fully initialise itself.

### Unparsable Password

The password you choose for Jupyter and your encrypted volume, to be
safe, should be limited to (Latin) alphanumeric characters (i.e.,
`[a-zA-Z0-9]`). The more characters you have, the better. Symbols and
other special characters *may* work in your password, per the [YAML
specifications](https://yaml.org/spec/1.1/), but you use these at your
own risk.

If you use special characters that the provisioning software can't
understand, you will see an error like this in your provisioning logs:

```
ERROR! Syntax Error while loading YAML.
  found unknown escape character
```

After this message will be the exact details of the failure, in which
you should see a reference to `password`. To resolve this, you will need
to destroy the cluster *and the volume*, then rebuild with a less-exotic
password:

```bash
bash invoke.sh hail destroy --yes-also-hail-volume
bash invoke.sh hail create
```

**Warning** Destroying the volume will result in irrecoverable data
loss. This issue should only every occur when building your cluster for
the first time, in any particular environment, where your volume will be
empty. If you have any doubts about this, please contact HGI first.

## Hail Hangs

Check the Hail logs; if those aren't helpful, check the Spark logs and
status.

### Lack of Resources

If you see the following in your Hail logs:

```
TaskSchedulerImpl: WARN: Initial job has not accepted any resources; check your cluster UI to ensure that workers are registered and have sufficient resources
```

It can mean one of two things:

1. The workers in your cluster are too small to do the job you've asked
   of it.

2. There's something underlyingly wrong with the OpenStack tenant's
   networking.

The latter is rare and will affect everyone; it is an issue for HGI to
resolve. The first is, however, quite common. If you have built your
cluster from workers without enough resources (typically memory), you
will need to edit your configuration to use a larger
[flavour](https://ssg-confluence.internal.sanger.ac.uk/display/OPENSTACK/Flavours)
and then rebuild your cluster.

HGI would recommend starting with an `m1.medium` or `m2.medium` and
moving up from there. Do not jump to the very large flavours, as there
may not be quota for these machines and their configuration is not
necessarily better.
