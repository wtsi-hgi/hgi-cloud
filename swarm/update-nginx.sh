#!/bin/bash

stack="dockerSwarm"                                                                                                                        
                                                                                                                                           
docker service scale ${stack}_nginx=0                                                                                                      
docker service update --config-rm ${stack}_nginx_config ${stack}_nginx                                                                     
docker config rm ${stack}_nginx_config                                                                                                     
docker config create ${stack}_nginx_config /home/ubuntu/swarm/nginx.conf                                                                   
docker service update --config-add source=${stack}_nginx_config,target=/etc/nginx/nginx.conf ${stack}_nginx                                
docker service scale ${stack}_nginx=1     
