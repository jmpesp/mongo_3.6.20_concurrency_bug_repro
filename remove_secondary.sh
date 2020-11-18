#!/bin/bash

if [[ ${#} -lt 1 ]];
then
    echo "port please"
    exit 1
fi

set -x

docker exec mongo-$1 mongo --eval "db.getSiblingDB('admin').shutdownServer()"
docker exec -t mongo-27017 mongo --eval "rs.remove(\"$(docker inspect mongo-$1 | jq -r .[0].Config.Hostname):27017\")"

docker stop mongo-$1
docker rm mongo-$1

