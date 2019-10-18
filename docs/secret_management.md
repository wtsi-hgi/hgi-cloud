# A Guide to Secret Management

Secrets could be passwords, keys, certificates, sensitive environment data or any other custom data that a developer wants to protect e.g a database name, the administrator username, etc.


> "Often one has, as part of their cluster, a database of sorts which contains all the configuration and somehow interacts with both TF and Ansible. I don't know how it works exactly, just that it's a thing. Consul is a popular one; it's a key-value DB that I presume TF has a provider for. I guess Ansible can just talk to it natively" - A senior developer at Sanger



Running a Docker container in production should be the assembly of an image with various configuration and secrets. It doesn’t matter if you are running this container in Docker, Kubernetes, Swarm or another orchestration layer, the orchestration platform should be responsible for creating containers by assembling these parts into a running container.



## Anti-Pattern: Passing Environment variables (through CLI, Docker-Compose etc.)

(https://diogomonica.com/2017/03/27/why-you-shouldnt-use-env-variables-for-secret-data/)

It’s usual to configure connection data, including credentials, using environment variables 

```bash
$ docker service create \
 --name my-service \
 -e DB_HOST=my-db-service \
 -e DB_USER=my-db-user \
 -e DB_PASS=my-password \
 alpine while
```

This allows you to make it portable, you just need to change the environment variables to port the same image from development, to staging, to production or anywhere else.
But it has a drawback, you are making “public” your connection credentials and anybody with read access to your cluster could get your data:

```bash
$ docker service inspect my-service --format '{{ .Spec.TaskTemplate.ContainerSpec.Env | json }}' | jq
[
  "DB_HOST=my-db-service",
  "DB_USER=my-db-user",
  "DB_PASS=my-password"



$ docker exec -it \
    $(docker ps --filter "name=my-service." -q) \
    printenv | grep DB_
DB_HOST=my-db-service
DB_USER=my-db-user
DB_PASS=my-password
```
## Anti-Pattern: Embed configuration or secrets in Docker Images  (INSECURE: ) 

 [Don't do this](https://medium.com/@mccode/dont-embed-configuration-or-secrets-in-docker-images-7b2e0f916fdd). This makes the image either insecure (if it is uploaded to a centralised repository like DockerHub), or unusable (if it is built in a local repository everytime). These values don’t belong in the image, they belong only in the running container.



## Anti-Pattern:  Copying a Configuration File and Injecting it Manually 

This is not only tedious, but doesn't work well with swarm since the services can be scheduled on any host in an automated way, so injection of config is not always possible.

## Bind Mount Secrets to Containers. 

- If you bind mount a host path into your service’s containers, the path must exist on every swarm node. The Docker swarm mode scheduler can schedule containers on any machine that meets resource availability requirements and satisfies all constraints and placement preferences you specify. So you have to make sure the path is available to every node in the cluster the task can be scheduled to. But even with this approach container can be scheduled to a node with no or outdated data. So it is better to pin services to concrete nodes.

-  (IMPOSSIBLE WITH HOST MOUNTED VOLUMES (Cinder Service) . 
-  Might be POSSIBLE WITH “Cluster filesystem” like CEPH - but how? )
-  Bind Mounting to container Config files (e.g. sourcing hgi-openrc.sh at runtime. But this should be available to the docker container through a bind mounted volume, e.g.) Bindmounting issues in swarm: cannot be done/has to be done on all nodes.  

## Using an configuration management solution. This can be an internal config management service (etcd: etcd is a distributed reliable key-value store ), or an external service :  https://gist.github.com/maxvt/bb49a6c7243163b8120625fc8ae3f3cd

### Ansible Vault


Ansible Vault is a feature of ansible that allows you to keep sensitive data such as passwords or keys in encrypted files, rather than as plaintext in playbooks or roles. These vault files can then be distributed or placed in source control.
This is Ansible's built in secret management system, based on encrypting secrets into a file. Its usage can be more general than Chef's encrypted data bags, as it can be applied to tasks, handlers, etc. and not just to variables; but it is not transparent, in the sense that some tasks will be configured differently when encryption is used. A command line tool is provided to manage the process, and the suggested workflow is to check the encrypted files into source control. There does not appear to be a way to have more than one password for a file, or to define different types of access to a secret, or to audit access.
If you are using Ansible and your main goal is to get the secrets out of plaintext files, this would probably be your natural choice.





There are many ways that a container can be provided secrets and configuration at runtime

### Docker secrets. 

Docker Secrets is only available in the Swarm mode, so standalone containers can not use this feature/ Datacenter Operating System, Kubernetes and other orchestration technologies have their own integrated secrets management solutions. Managers in Docker Swarm act as an authoritative delegation to coordinate secrets management.
When a user adds a new secret to a Swarm cluster, this secret is sent to a manager using a TLS connection.



### Kubernetes

Switch to Kubernetes and take advantage of automated volume provisioning using multiple backends via Storage classes and claims.

￼




References:
[Link](https://www.youtube.com/watch?v=OUSvv2maMYI&feature=youtu.be)
[Link](https://www.hashicorp.com/resources/securing-container-secrets-vault)
[Link](https://github.com/moby/moby/issues/26944)
[Link](https://github.com/moby/moby/issues/24430)
[Link](https://github.com/docker/compose/issues/5523)
[Link](https://medium.com/lucjuggery/from-env-variables-to-docker-secrets-bc8802cacdfd)
[Link](https://github.com/koslibpro/tf-aws-docker-swarm/blob/master/swarm.tf 
[Link](https://read.acloud.guru/deploy-a-docker-swarm-cluster-on-gcp-with-terraform-dc1c40bb062e)

How to expand secret to expand into env variables?

(https://stackoverflow.com/questions/48094850/docker-stack-setting-environment-variable-from-secrets)
(https://medium.com/@basi/docker-environment-variables-expanded-from-secrets-8fa70617b3bc)
