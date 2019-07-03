#!/bin/bash

NETWORK=dev-net
SERVICE=canvas
VERSION=0.1
PORT=57111

# input with four arguments: go.sh SERVICE VERSION NETWORK PORT
if [ "$1" != "" ]; then
        SERVICE=$1
fi
if [ "$2" != "" ]; then
        VERSION=$2
fi
if [ "$3" != "" ]; then
        NETWORK=$3
fi
if [ "$4" != "" ]; then
        PORT=$4
fi
if [ "$5" != "" ]; then
        PASSWORD=$5
fi

# reuse input
export STACK_SERVICE=$SERVICE
export STACK_VERSION=$VERSION
export STACK_NETWORK=$NETWORK
export STACK_PORT=$PORT
export STACK_PORT2=$PORT+1
export STACK_PASSWORD=$PASSWORD

if [ $NETWORK == "dev-net" ]; then
        export STACK_DOMAIN=lms.dev.dlo.surf.nl
fi
if [ $NETWORK == "test-net" ]; then
        export STACK_DOMAIN=lms.test.dlo.surf.nl
fi
if [ $NETWORK == "exp-net" ]; then
        export STACK_DOMAIN=lms.experimenteer.dlo.surf.nl
fi

# delete previous version
# note: geen rollback!
docker stack rm $STACK_SERVICE


# prepare
./prepare.sh

# go
docker stack deploy --with-registry-auth -c docker-compose.yml $STACK_SERVICE
