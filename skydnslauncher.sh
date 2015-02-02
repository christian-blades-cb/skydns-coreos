#!/usr/bin/env bash

# If ETCD_HOSTS isn't populated, assume that the docker host is the
# gateway on the default route. If we're in CoreOS, ETCD will be
# running there on port 4001

if [ -z "$ETCD_HOSTS" ]; then
    docker_host=$(ip route | grep default | cut -d' ' -f3)
    >&2 echo "Host found at ${docker_host}"
    export ETCD_MACHINES="http://${docker_host}:4001"
fi

skydns $@
