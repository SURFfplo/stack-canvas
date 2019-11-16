#!/bin/bash

#first clean old stack if it exists
match=$( docker stack ls | grep -i "$STACK_SERVICE")
if [ "$match" ]; then
    docker stack rm $STACK_SERVICE
fi
sleep 10

# clean mounts
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/conf
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/data
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/redis
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/brandable_css
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/tmp


# create nfs mount
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/conf
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/data
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/redis
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/brandable_css
mkdir -p /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/tmp



# Add config files and exexcutables to setup canvas
cp ./deploy/* /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/conf

# remove any old secrest and configs
docker config rm $(docker config ls -f name=canvas -q)
# do not rmove secrets automaticially otherwhise api eys need to be reconfigured over all systems
#docker secret rm $(docker secret ls -f name=canvas -q)

# create secrets for database
# e.g. date |md5sum|awk '{print $1}' | docker secret create my_secret -
# or cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | docker secret create canvas_db_dba_password -
# or visible printf "pasword"  | docker secret create canvas_db_dba_password -
date |md5sum|awk '{print $1}' | docker secret create canvas_db_dba_password -
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 40 | head -n 1 | docker secret create canvas_secret_api -


#create two run once services for initialisation purposes
#disabled so database does not gets rebuilt
docker stack deploy --with-registry-auth --compose-file docker-compose.init.yml $STACK_SERVICE
sleep 200
docker stack deploy --with-registry-auth --compose-file docker-compose.init2.yml $STACK_SERVICE
sleep 200
#remove passowrd from system after initial setup
export STACK_PASSWORD=""
docker stack deploy --with-registry-auth --compose-file docker-compose.init3.yml $STACK_SERVICE
sleep 300

