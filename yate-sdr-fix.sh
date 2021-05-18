#! /usr/bin/bash

source .env

ENB=/etc/yate/sdr/yateenb.conf
GTP=/etc/yate/sdr/gtp.conf
sed -i "s/MCC=.*$/MCC=$MCC/" "$ENB"
sed -i "s/MNC=.*$/MNC=$MNC/" "$ENB"
sed -i "s/TAC=.*$/TAC=$TAC/" "$ENB"
sed -i "s/local=.*$/local=100.77.0.1/" "$ENB"
sed -i "s/address=.*$/address=$MME_IP/" "$ENB"
sed -i "s/addr4=.*$/addr4=$MME_IP/" "$GTP"
service yate-sdr restart
