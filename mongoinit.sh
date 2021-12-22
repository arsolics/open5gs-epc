#! /usr/bin/bash
source .env

rm -f sims.json
count=0
myap=" "
for ap in ${APN[@]}
do
	if [[ $count -eq 0 ]];
	then
		myap="$myap{ 'apn' : '$ap', 'pcc_rule' : [ ] , 'ambr' : { 'downlink' : '512000' , 'uplink' : '512000' } , 'qos' : { 'qci' : 9, 'arp' : { 'priority_level' : 8 , 'pre_emption_vulnerability' : 1, 'pre_emption_capability' : 1 } } , 'type' : 2 }"
	else
		myap="$myap , { 'apn' : '$ap', 'pcc_rule' : [ ] , 'ambr' : { 'downlink' : '512000' , 'uplink' : '512000' } , 'qos' : { 'qci' : 9, 'arp' : { 'priority_level' : 8 , 'pre_emption_vulnerability' : 1, 'pre_emption_capability' : 1 } } , 'type' : 2 }"
	fi
	count=$((count+1))
done
while read -r l 
do

IMSI=`echo $l | cut -d ',' -f 3`
K=`echo $l | cut -d ',' -f 10`
OPC=`echo $l | cut -d ',' -f 11 | tr -d '\r'`
AMF=`echo $l | cut -d ',' -f 9`
AMF=9001

echo "{ 'imsi' : '$IMSI', 'pdn': [ $myap ] , 'ambr' : { 'downlink' : '512000' , 'uplink' : '512000' } , 'subscribed_rau_tau_timer' : 12, 'network_access_mode' : 2, 'subscriber_status' : 0, 'access_restriction_data' : 32, 'security' : { 'k' : '$K', 'amf': '$AMF', 'op' : null, 'opc': '$OPC'}, '__v' : 0 }"



done < ./sims/sims.csv > sims.json
echo "db.subscribers.remove( { } )" | docker exec -i mongo mongo 100.77.0.2/open5gs --
docker cp sims/sims.json mongo:/mnt/sims.json
docker exec -it mongo mongoimport -h 100.77.0.2 -d open5gs -c subscribers /mnt/sims.json
