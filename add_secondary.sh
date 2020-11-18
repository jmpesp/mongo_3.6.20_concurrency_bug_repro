#!/bin/bash

if [[ ${#} -lt 1 ]];
then
    echo "port please"
    exit 1
fi

primary_ip=`./docker_ips mongo-27017`

set -ex

. mongo_version

docker run --rm -d \
    -p "${1}:27017" \
    --name "mongo-${1}" \
    ${MONGO_VERSION} \
        mongod --bind_ip 0.0.0.0 --replSet "rs0"

secondary_ip=`./docker_ips mongo-$1`

docker exec mongo-$1 bash -c "echo '$primary_ip' >> /etc/hosts"
docker exec mongo-27017 bash -c "echo '$secondary_ip' >> /etc/hosts"

docker exec -t mongo-27017 mongo --eval "rs.add(\"$(docker inspect mongo-$1 | jq -r .[0].Config.Hostname)\")"

