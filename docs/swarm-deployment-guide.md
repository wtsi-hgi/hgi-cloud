
# How to test a web app before deploying to swarm?


* Test on local dev server
    * If everything is fine, push changes to centralized version control (e.g. github)
* Test on remote cloud instance and build docker image
    * Pull from github
    * Test app; especially routing is working on the app-level in production mode 
    *  If everything is fine, build docker image increase version number (e.g. mercury/gwas:0.7)
    *  Push to Docker Hub with mercury's credentials. Note that for the image has to be named in the format mercury/<image_name>: <version_tag>
* Test on test swarm
    - For new apps, update nginx configuration to route incoming requests to app. For existing apps the existing nginx configuration would probably work, but might need to be changed depending on the feature
    - Update docker-compose file (especially the version tag in image)
    - Redeploy the stack on test swarm
     ```
     docker stack deploy --with-registry-auth  --compose-file docker-compose.yml app
     ``` 
     `--with-registry-auth` is needed so that all nodes are able to download the new image.
    - Test proxy server routing
* Few Things you can do to help with testing:
    * For first time apps, you might want to check whether the app is correctly being hosted within the swarm without the hassles of the proxy level routing and the auth layer/security features. For this, expose port directly within in your compose file. Make sure you update the security groups of your swarm layer. 
    * For hot fixes or making minor changes on swarm test layer, it can take a lot of work in pushing the changes to github, rebuilding the image, and pulling the new image. You might want to skip this process and place the change directly in the running container and restart it. (This can be tricky because the root process of a container cannot be stopped without shutting down the container. When its a server, it blocks a port.)
    
    For example: 

        ```
        docker cp data_old.json  app_gwas-db.1.25jla4z9b8y9rzxutnyq7m011:/data/variants_nmr.json
        ```
    * If you are facing networking issues, you might want to check whether the container is actually running ('docker service ls'). If it is, you might want to check whether it is responding to requests (`curl -H "X-Forwarded-User: pa11"  localhost:3001/api/variant/nmr_mldlce`) from within the swarm first. Since this will bypass nginx, make sure you add an appropriate headers in your curl request. 



# Files Needed for Swarm

For Swarm Infrastructure (SSL configs, proxy server configs and container definitions )
- nginx.conf (for proxy server)
- docker-compose.yml
- ssl certificate: apps\_hgi\_sanger\_ac\_uk-cert.pem
- ssl key: apps\_hgi\_sanger\_ac\_uk-key.pem

If your app needs configuration (for example, for passing in different values in dev and prod environments), there are a few options:

- Bake the configuration file within the docker image (BAD PRACTICE)
- Mount the configuration file from the host machine when the container starts
- Pass variables as the `command` option in the compose file
- Have different Dockerfile defined for production, testing and dev

[Example](https://stackoverflow.com/questions/39686643/production-vs-development-docker-setup-for-node-express-mongo-app)

Currently, we the swarm expects the following app specific configuration files defined in the compose file for mounting:

- gwas: `gwas_whitelist`
- cluster-report: `hgi-openrc.sh`
- weaver: `config.yml`


These files are corrently located in the directory `hgi-cloud/swarm` in the `feature/dockerSwarm` branch of the `hgi-cloud` repo. 

# Swarm Auth Layer

The auth layer is implemented using a slight modification of [this repo](https://github.com/nginxinc/nginx-ldap-auth).

Swarm Auth Layer is Managed by two containers: `mercury/nginx-ldap-auth-daemon:test` and `mercury/auth-login-page:latest`.

The nginx-ldap-auth-daemon decodes the `nginxauth` cookie received from the client and authenticates against the Sanger LDAP server. If authentication is successful, it sets a `X-Forwarded-User` header and redirects to nginx proxy server. nginx proxy server then forwards the request (along with the header) to any downstream apps. The downstream apps can use the `X-Forwarded-User` header for any authorization purposes.  

Technically, the `auth-login-page` container is not strictly necessary. In its absence, the `ldap-auth-daemon` reverts to basic auth under which mechamism the browser encodes the credentials in the `Authorization` header (as opposed to a cookie) with the scheme "base64(user : password)". The`ldap-auth-daemon` decodes this. But having a `login-page` affords us greater flexibility into what to request from the client and how to.


# Persistence layer in Swarm

Containers within a swarm can be replicated, allocated to a different host, shut down, restarted etc. Hence they are not really defined for persisting state, as is required by a db.  One workaround to persisting state is to create a volume and bind mount it to a container. But for this to work, the data stored in the volume must be in the same node as where the container is deployed. Hence, sometimes it is useful to define constraints in the compose file to restrict the container to a particular node. We do this, for example, in the db container for gwas app as shown:

```
  gwas-db:
    image: mongo:bionic
    volumes:
      - gwasdb:/data/db
    networks: [app]
    deploy:
      placement:
        constraints:
          - "node.role==manager"
```




