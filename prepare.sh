#!/bin/bash

# create nfs mount
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/conf
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/data
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE-$STACK_VERSION/redis


# create secrets for database
# alternative date |md5sum|awk '{print $1}' | docker secret create my_secret -
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | docker secret create canvas_db_root_password -

# create configs for canvas
docker config create canvas_cache deploy/cache.yml
docker config create canvas_database deploy/database.yml
docker config create canvas_delayed_jobs deploy/delayed_jobs.yml
docker config create canvas_dev_loc deploy/development-local.rb
docker config create canvas_domain deploy/domain.yml
docker config create canvas_outgoing_mail deploy/outgoing_mail.yml
docker config create canvas_redis deploy/redis.yml
docker config create canvas_security deploy/security.yml








