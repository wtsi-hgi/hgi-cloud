# terraform
This is the home of all the terraform modules and variables files.

# Why such a module hierarchy?
There are 2 main reasons why the hierarchy has been designed in this way:
1. Within reason, support multiple cloud provider.
2. Create a high and a low level API interface between terrform
   users/designers and developers. Users should be able to define/extend an
   infrastructure on different cloud platforms, without the need to know what
   terraform resources they need to define and combine.

# The module hierarchy

## vars/
The directory containing `terraform` variables file that can be used with the
`terraform`'s `-var-file` cli option flag.

## modules/
The directory containing all the modules. The first sublevel is made of one
directory for each cloud provider managed by this project. Only `openstack` is
available at the moment of this writing, but more might be added later.

### modules/\<cloud\_provider\>/deployments/
Modules in this directory are responsible for the deployment of a simple group f
service, like a `spark-cluster`, a `consul-cluster`, an `ssh-gateway` etc. They
may expect some parts of an environment already up and runnig, and might not
be designed to work stand-alone. They are not supposed to directly create
resources in Openstack; instead the should use lower level modules located in
`modules/<cloud_provider>/infrastructure`.

### modules/\<cloud\_provider\>/infrastructure/
Modules in this directory are responsible for the deployment of the actual
resources in Openstack, like `instances`, `networks`, `secgroups` etc. When
creating a new infrastructure module, our best effort should be to create a
minimal resource. Every time extra bits can be defined/attached to the
resource at hand, they should go in an `extra` sub-module. For instance 
`modules/openstack/infrastructure/instances/extra/external_ip` attaches an
Openstack's `floating_ip` to an instance.
