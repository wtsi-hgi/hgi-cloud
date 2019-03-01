# hgi-systems-cluster-spark

A reboot of the HGI's IaC project. This specific project has been created to
address one, simple, initial objective: the lifecycle management of a spark cluster.

# Why a reboot?

The code was not effective any more: the team was not confident with the
codebase, the building process and the infrastructure generated by the code
was missing a number of must-have features for today's infrastructures.
We chose to have a fresh start on the IaC, rather then refactoring legacy
code. This will let us choose simple and effective objectives, outline better
requirements, and design around operability from the very beginning.

# Usage

## What do you need?
1. (required) `terraform` executable anywhere in your `PATH`
2. (optional) `python3` interpreter anywhere in your `PATH`
3. (optional) `virtualenv` executable anywhere in your `PATH`
4. (optional) `openrc.sh` OpenStack's RC file, that you can get from
   OpenStack's web interface

## The easy way
The easy way is to use the `invoke` shellscript in the base directory of this
project, given that you have `python3`, `virtualenv` and `openrc.sh` available:
`invoke` will create the python3 virtualenv with all the dependencies, read all
the bash environment variables in `openrc.sh` and then run the appropriate
tasks.

To create the infrastructure:
```
bash invoke creation
```

To update the infrastructure:
```
bash invoke plan --to update
# Check the plan
bash invoke update
```

To destroy the infrastructure:
```
bash invoke plan --to destroy
# Check the plan
bash invoke destruction
```

## The hard way
If you know your way around `OpenStack` and `terraform`, you will be able to
setup the bash environment variables you need, and then run the appropriate
terraform commands to get your tasks done. Feel free to take inspiration from
`invoke` and all the `tasks.py` files you can find.

# Architecture
TODO: include a simple design diagram

# Design choices
TODO: write down a small paragraph about any design choice.

# Use cases

## Create a Spark Cluster
TODO: wirte down the use case's details

## Destroy a Spark Cluster
TODO: wirte down the use case's details

# How to contribute
Read the [CONTRIBUTING.md](CONTRIBUTING.md) file

# Licese
Read the [LICENSE.md](LICENSE.md) file
