## Pyinvoke and invoke.sh
[Pyinvoke](https://www.pyinvoke.org) is:
> a Python (2.7 and 3.4+) task execution tool & library, drawing inspiration from
> various sources
like:
- Ruby’s Rake
- GNU Make
- Fabric

# Why did I introduce invoke?
1. This repository/project is aimed at users who might not be familiar with all
   the tools used to create any part of the infrastructure, the order in which
   they have to be used, or any step at all; in all honesty, they don't need
   to. What they need is a clear, simple interface to create/update/destroy the
   entire infrastructure or even parts of it.
2. Some of the values used in configuration files are IDs, and it has never been
   handy to work with IDs. The reason why some values are IDs is, for instance,
   that there is not a unique way to map some names into IDs (and vice versa),
   simply beacuse some objects are allowed to be colled with the same name,
   despite being distinct instances; therefore the tools, sometimes, relies on
   IDs to create the expected outcome. However, given that this code is
   supposed to work only within a specific context, with specific rules and
   conventions, we can do this mapping before feeding the values to the tools.

# Design choices
There are 3 kinds of files inside this directory.

## Configuration files
These are files with a `.yaml` extension. They are meant to be configration
files for `pyinvoke`, however there should not be the need for any
configuration file other than `invoke.yaml`.

## Tasks libraries
These are python files with a name suffix of `_tasks`, i.e.
`terraform_tasks.py`. They are meant to be libraries of tasks and namespaces
definitions that can be imported by [tasks collections](#tasks-collections)

## Tasks collections
These are python files with a name suffix of `_collection`, i.e.
`common_environment_collection.py`. They are meant to import and compose tasks
and namespaces from [tasks libraries](#tasks-libraries) and create the
interface through which the users are going to execute all the steps required
to get their job done.

# Usage

## What do you need?
1. (required) `python3` interpreter anywhere in your `PATH`
2. (required) `virtualenv` executable anywhere in your `PATH`
3. (required) `invoke` python module installed

# Running tasks
Since you can run are so many tasks with so many different opsions, in order to
run tasks using the `invoke` command (not to be confused with `invoke.sh`), you
need to specify a task collection file with the `-c|--collection` option:
```
invoke --collection "invoke/base_image_collection" build
```
For more details on how to run `invoke`, refer to `invoke`'s
[documentation](http://docs.pyinvoke.org/en/1.2).
