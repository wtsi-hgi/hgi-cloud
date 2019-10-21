# Introduction

This is the documentation for bringing up a Docker swarm cluster, intended for
end-users. Before you continue reading, there are some terms and values
that you need to know.

## Why Docker Swarm?


- Scalability: Sometimes one host is not enough to run all the services or all serve all the requests. Docker swarm turns a pool of Docker hosts into a single, large, virtual Docker host.
- State Maintenance: Swarm automates the maintenance of our infrastructure state. For example, we can configure swarm with the number of replicas of a service that need to be running.The swarm would automatically monitors the service and schedule it on an appropriate machine if it goes down for some reason. 
- Modify configuration with minimum downtime: With swarm, we can reconfugure network, add volumes or security groups at a later date, and swarm would just take care that services are interrupted minimally (if one goes down or needs restart, swarm ensures it is started)



# How to set up a new user?


1. **Ensure the docker-main network is available**
Docker Swarm runs on its on network, which needs to exists on a tenant prior to creating a swarm cluser. To set up the networking, run:

`bash invoke docker create --networking`

2. **Ensure an appropriate base image is configured and avaiable**


A swarm cluster uses an image based on the `docker-base` ansible role: 'eta-hgi-image-docker-base-0.1.2'. This image needs to exist on the tenant. 
If it does not, then run:

`bash invoke.sh image share`

followed by 

`Openstack image set —accept <imageid>`


If needed, the image name can be configured in the corresponding terraform variable file:

Path: `terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}.tfvars`

Attributes to modify:

- `docker_manager_image_name`    
- `docker_worker_image_name`


2. **Set up user-specific terraform Variables**

Run this command:

`touch terraform/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/docker_swarm.tfvars`

And in the docker_swarm.tfvars file, add:

`docker_manager_external_address = <Floating IP address>`

3. **Set up user-specific ansible variables**

`mkdir --parents ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/docker_swarm`

```bash
for yml in 
  ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/docker_swarm.yml \
  ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/docker_swarm/docker-swarm-manager.yml \
  ansible/vars/${META_DATACENTER}/${META_PROGRAMME}/${META_ENV}/${OS_USERNAME}/docker_swarm/docker-swarm-worker.yml
do
  test -f ${yml} || echo -e "---\n{}" > ${yml}
done
```




# How to deploy a new service to the Swarm?

## Method 1
Copy the following secret files and the compose files (which has the secret and service definitions) to the swarm manager and run:

`docker stack deploy`

Example of secret files:

- `Hgi-openrc.sh`
- `config.yml`


## Method 2

This requires `pip install jsondiff` on manager:

For each secret used in the compose file:

`scp -i /path/to/hermes_private_key  /path/to/secret_file ubuntu@<Swarm Manager IP address>:~`

`ansible all --key-file -i /path/to/hermes_private_key  -i '<Swarm Manager IP address>,'-m docker_stack -a "name=app compose=docker-compose.yml" -vvv`

Ensure any additional port is opened in the in the `docker_swarm_web_app` security group (which allows TCP ingress on Ports 80-100)

# How to define a service in compose file?

```yaml
services:
  backend:
    image: mercury/openstack_report_backend:v2.0 
    ports: 
      - "3000:3000"
    secrets:
      - source: backend_secret
        target: /app/hgi-openrc.sh
  frontend:
    image: mercury/openstack_report_frontend:v2.0
    ports: 
      - "8080:8080"
    depends_on: 
    - backend
secrets:
   backend_secret:
      file: hgi-openrc.sh
```

## List of Secret Files

The following are files which store various credentials and other sensitive information used by individual apps in the docker swarm. 

### Application: Weaver

`config.yml`

### Application: Cluster Report

`hgi-openrc.sh`



# Troubleshoot

- Terraform returns with succesful provisioning even if the bootup script is still running in the background (the bootup script that sets up the swarm does many tasks: in).  As a result, the swarm might not be up until after some time.

- Security Groups, including the one corresponding to swarm (`docker_swarm_web_app`) is hard-coded in the terraform script. Any change in them through other channels is going to break terraform. 

- DNS Issues: 
  - By default, docker allocates the subnet corresponding to 172.17.0.0/16, if available, for the network `docker_gwbridge` on each host. If the subnet is not available, it looks for, in order: 172.18.0.0/16, 172.19.0.0/16...and so on. 
  - Because 172.17.*.* is used by Weaver to talk to SQL Server, and the Sanger DNS servers are 172.18.255.1, 2 and 3, both these subnets are relevant to us. If docker_gwbridge is allocated either of these, the DNS resolution on the swarm stops working.
  - For this reason, we reserve two dummy networks corresponding to 172.17.0.0/30 and 172.18.0.0/30 on each node at the time of provisioning, before the swarm initation. 
  - If any of the IP address from 172.17.0.0/30 and 172.18.0.0/30 or 172.19.0.0/16 are ever needed for an app, the provisining tasks would need to unblock these and reserve something else for docker_gwbridge for the app to work.


- Multiple Managers:  A swarm cluster, just like a hail cluster, just supports one manager node. If there's a use-case for multiple managers: extra managers could join the cluster in the exact same way the workers do, just using the appropriate token discovered through docker-swarm-info
  
- Authorized Keys: The following task in the Commons role adds authorised keys from a variable named authorized_keys: https://github.com/wtsi-hgi/hgi-cloud/blob/develop/ansible/roles/common/tasks/main.yml#L81-L87. For example, the authorised keys for Hermes and ISG is in here: https://github.com/wtsi-hgi/hgi-cloud/blob/develop/ansible/roles/hail-common/vars/main.yml 

- Bind mounting a host directory into a service is not well-supported on docker swarm. If you bind mount a host path into your service’s containers, the path must exist on every swarm node. The Docker swarm mode scheduler can schedule containers on any machine that meets resource availability requirements and satisfies all constraints and placement preferences you specify. So you have to make sure the path is available to every node in the cluster the task can be scheduled to. But even with this approach container can be scheduled to a node with no or outdated data. So if it has to be done, it is better to pin services to concrete nodes.

- For some mysterious reason, as a default the user `ubuntu` is unable to talk to the docker daemo on the manager node, even if the user is manually added. For this reason, during provisioning, we loosen the permisions of the docker socket to be open to all users. (This may or maynot be a security risk)

- 







