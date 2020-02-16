#!/bin/bash

#first clean old stack if it exists
match=$( docker stack ls | grep -i "$STACK_SERVICE")
if [ "$match" ]; then
    docker stack rm $STACK_SERVICE
fi

#in order to remove succesfully take time to unmount ande spin down containers
sleep 30


# clean mounts
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/conf
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/data
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/redis
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/brandable_css
sudo rm -rf /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/tmp
echo "cleaning mounts succesful"

# create nfs mount and set it to default user UID and GID
sudo install -d -m 0755 -o 9999 -g 9999 /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/conf
sudo install -d -m 0755 -o 9999 -g 9999 /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/data
sudo install -d -m 0755 -o 9999 -g 9999 /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/redis
sudo install -d -m 0755 -o 9999 -g 9999 /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/brandable_css
sudo install -d -m 0755 -o 9999 -g 9999 /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/tmp
echo "restore mounts sucessful"

# do not rmove secrets automaticially otherwhise api eys need to be reconfigured over all systems
docker secret rm $(docker secret ls -f name="$STACK_SERVICE" -q)

#set secret in yml file and in secrets file for docker
secret=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 40 | head -n 1)
#start with empty security.yml
FILE=deploy/security.yml_org
if [ -f "$FILE" ]; then
    echo "$FILE exists so copy contents"
    cp ./deploy/security.yml_org ./deploy/security.yml
else 
    echo "$FILE does not exist"
fi
cp ./deploy/security.yml ./deploy/security.yml_org && sed "s/12345/$secret/g" ./deploy/security.yml > ./deploy/sec_test.yml
cp ./deploy/sec_test.yml ./deploy/security.yml
echo "$secret" | docker secret create $STACK_SECRET -

# create developer API key
api_key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
echo "$api_key" | docker secret create $STACK_API_KEY -


# Add config files and exexcutables to setup canvas
cp ./deploy/* /mnt/nfs/nfsdlo/$STACK_NETWORK/$STACK_SERVICE/$STACK_VERSION/conf


# create secrets for database
# e.g. date |md5sum|awk '{print $1}' | docker secret create my_secret -
# or cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | docker secret create canvas_db_dba_password -
# or visible printf "pasword"  | docker secret create canvas_db_dba_password -
date |md5sum|awk '{print $1}' | docker secret create $STACK_DB_DBA_PASSWORD -
cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 40 | head -n 1 | docker secret create $STACK_SECRET_API -


#create two run once services for initialisation purposes
#disabled so database does not gets rebuilt
docker stack deploy --with-registry-auth --compose-file docker-compose.init.yml $STACK_SERVICE
sleep 300
docker stack deploy --with-registry-auth --compose-file docker-compose.init2.yml $STACK_SERVICE
sleep 200
#remove passowrd from system after initial setup
export STACK_PASSWORD=""
docker stack deploy --with-registry-auth --compose-file docker-compose.init3.yml $STACK_SERVICE
sleep 300

