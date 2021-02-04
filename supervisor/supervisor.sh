#! /bin/bash


. /root/docker_open5gs/.env 

fs=""

echo "This will sleep for 120 seconds, take a break."
sleep 120
for s in $OVPN_ROUTED_SERVICES
do
fs="$fs --filter 'container=$s'"
/root/docker_open5gs/supervisor/route.sh $s



done 


echo $fs

screen -d -m -S events docker events $fs --filter 'event=start' --filter 'event=stop' --format '{{.Actor.Attributes.name}}'|awk '{ system("/root/docker_open5gs/supervisor/route.sh " $1) }'




