#!/bin/bash

# this assumes below that the new .pem cert file is at /home/ubuntu/swarm/apps_hgi_sanger_ac_uk-cert.pem  

docker service scale ${stack}_nginx=0                                                                                                      
docker service update --config-rm ${stack}_ssl_cert ${stack}_nginx                                                                         
docker config rm ${stack}_ssl_cert                                                                                                         
docker config create ${stack}_ssl_cert /home/ubuntu/swarm/apps_hgi_sanger_ac_uk-cert.pem                                                   
docker service update --config-add source=${stack}_ssl_cert,target=/etc/nginx/etc/ssl/certs/apps_hgi_sanger_ac_uk-cert.pem ${stack}_nginx  
docker service scale ${stack}_nginx=1 

# refreshing all the services with info from docker-compose file: 
docker stack deploy --with-registry-auth --compose-file swarm/docker-compose.yml dockerSwarm
