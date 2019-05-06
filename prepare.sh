#!/bin/bash

# create nfs mount
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/conf
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/data
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/redis
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/brandable_css


# create secrets for database
# e.g. date |md5sum|awk '{print $1}' | docker secret create my_secret -
# or cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | docker secret create canvas_db_dba_password -
# or visible printf "pasword"  | docker secret create canvas_db_dba_password -
date |md5sum|awk '{print $1}' | docker secret create canvas_db_dba_password -


# create configs for canvas
docker config create canvas_cache deploy/cache.yml
docker config create canvas_database deploy/database.yml
docker config create canvas_delayed_jobs deploy/delayed_jobs.yml
docker config create canvas_dev_loc deploy/development-local.rb
docker config create canvas_domain deploy/domain.yml
docker config create canvas_outgoing_mail deploy/outgoing_mail.yml
docker config create canvas_redis deploy/redis.yml
docker config create canvas_security deploy/security.yml
docker config create canvas_wait wait-for-it.sh



#create two run once services for initialisation purposes
docker stack deploy --compose-file docker-compose.init.yml $STACK_SERVICE
sleep 100
docker stack deploy --compose-file docker-compose.init2.yml $STACK_SERVICE
sleep 100
# alternative sollutions
# to do remover services taht we will not use for initial
# docker stack deploy --compose-file docker-compose.yml -c docker-compose.prod.yml $STACK_SERVICE
# docker service rm $STACK_SERVICE_konga 
#"woit for 30 seconds for kong-db container to fully come up" 

# Initialize kong container
#temp_service < docker service create --restart-condition=none --detach=true --secret kong_db_dba_password --name kong-temp1 --env KONG_DATABASE=postgres --env KONG_PG_HOST=kong-db --env KONG_PG_PORT=5432 --env KONG_PG_DATABASE=api-gw --env KONG_PG_DB_PASSWORD_FILE=/run/secrets/kong_db_dba_password --network appnet kong-oidc kong migrations bootstrap
# docker stack rm $temp_service 
