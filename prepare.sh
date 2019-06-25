#!/bin/bash

# create nfs mount
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/conf
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/data
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/redis
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/brandable_css
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/tmp

#first clean old stack if it exists
match=$( docker stack ls | grep -i "$STACK_SERVICE")
if [ "$match" ]; then
    docker stack rm $STACK_SERVICE
fi
sleep 10

# remove any old secrest and configs
docker config rm $(docker config ls -f name=canvas -q)
docker secret rm $(docker secret ls -f name=canvas -q)

# create secrets for database
# e.g. date |md5sum|awk '{print $1}' | docker secret create my_secret -
# or cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | docker secret create canvas_db_dba_password -
# or visible printf "pasword"  | docker secret create canvas_db_dba_password -
date |md5sum|awk '{print $1}' | docker secret create canvas_db_dba_password -
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 40 | head -n 1 | docker secret create canvas_secret -

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
docker config create canvas_api startup.sh



#create two run once services for initialisation purposes
docker stack deploy --compose-file docker-compose.init.yml $STACK_SERVICE
sleep 200
docker stack deploy --compose-file docker-compose.init2.yml $STACK_SERVICE
sleep 200
docker stack deploy --compose-file docker-compose.init3.yml $STACK_SERVICE
sleep 200
