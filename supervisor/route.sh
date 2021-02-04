#!/bin/bash

. /root/docker_open5gs/.env 



# exit if no container name provided as $1
[ "x$1" = 'x' ] && exit 1
# holds pid of the docker container
pid=''
# read the pid for container
pid=$(docker inspect -f '{{.State.Pid}}' "${1}" 2>/dev/null)
logger "Routing for $1 with pid $pid"
# if for whatevery reason we get pid 0 avoid setting routes
[ "x$pid" = 'x0' ] && pid=''
if [ "x$pid" != 'x' ] ; then
  # let the routing happen 
  mkdir -p /var/run/netns
  ln -s /proc/$pid/ns/net /var/run/netns/$pid
  ip netns exec $pid ip route add $OVPN_POOL via $OVPN_IP
  rm /var/run/netns/$pid
fi
# clean up broken symlinks which occur when a container is stopped
# verify that your find supports -xtype l
find /var/run/netns -type l -exec rm -f '{}' \;
