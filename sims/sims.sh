#! /usr/bin/bash
while read -r l 
do

IMSI=`echo $l | cut -d ',' -f 3`
K=`echo $l | cut -d ',' -f 10`
OPC=`echo $l | cut -d ',' -f 11 | tr -d '\r'`
AMF=`echo $l | cut -d ',' -f 9`
AMF=9001


echo "{ 'imsi' : '$IMSI', 'pdn': [ { 'apn' : 'internet', 'pcc_rule' : [ ] , 'ambr' : { 'downlink' : '512000' , 'uplink' : '512000' } , 'qos' : { 'qci' : 9, 'arp' : { 'priority_level' : 8 , 'pre_emption_vulnerability' : 1, 'pre_emption_capability' : 1 } } , 'type' : 2 } ] , 'ambr' : { 'downlink' : '512000' , 'uplink' : '512000' } , 'subscribed_rau_tau_timer' : 12, 'network_access_mode' : 2, 'subscriber_status' : 0, 'access_restriction_data' : 32, 'security' : { 'k' : '$K', 'amf': '$AMF', 'op' : null, 'opc': '$OPC'}, '__v' : 0 }"


done < /root/work/sims/sims.csv > sims.json

