#!/bin/bash

set -e

. mongo_version

ports=("27017" "37017" "47017")
repl="rs0"

for port in "${ports[@]}"; do
    set -x
    docker run --rm -d \
        -p "${port}:27017" \
        --name "mongo-${port}" \
        ${MONGO_VERSION} \
            mongod --bind_ip 0.0.0.0 --replSet "${repl}"
    set +x
done

sleep 2

primary_ip=$(./docker_ips mongo-27017)

docker exec mongo-37017 bash -c "echo '$primary_ip' >> /etc/hosts"
docker exec mongo-47017 bash -c "echo '$primary_ip' >> /etc/hosts"

docker exec mongo-27017 bash -c "echo '$(./docker_ips mongo-37017)' >> /etc/hosts"
docker exec mongo-27017 bash -c "echo '$(./docker_ips mongo-47017)' >> /etc/hosts"

PRIMARY_HOSTNAME=$(docker inspect mongo-27017 | jq -r .[0].Config.Hostname) \
S1=$(docker inspect mongo-37017 | jq -r .[0].Config.Hostname) \
S2=$(docker inspect mongo-47017 | jq -r .[0].Config.Hostname) \
envsubst < initiate.tmpl | \
    docker exec -i mongo-27017 mongo

exit 0

