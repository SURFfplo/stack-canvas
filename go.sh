#!/bin/bash

export STACK_NETWORK=dev-net
export STACK_SERVICE=canvas
export STACK_VERSION=0.1

# prepare
./prepare.sh

# go
docker stack deploy -c docker-compose.yml $STACK_SERVICE
