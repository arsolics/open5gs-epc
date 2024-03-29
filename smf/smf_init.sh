#!/bin/bash

# BSD 2-Clause License

# Copyright (c) 2020, Supreeth Herle
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export IP_ADDR=$(awk 'END{print $1}' /etc/hosts)
export IF_NAME=$(ip r | awk '/default/ { print $5 }')

[ ${#MNC} == 3 ] && EPC_DOMAIN="epc.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || EPC_DOMAIN="epc.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

cp /mnt/smf/smf.yaml install/etc/open5gs
sed -i 's|SMF_IP|'$SMF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|NRF_IP|'$NRF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|UPF_IP|'$UPF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|PCRF_IP|'$PCRF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|EPC_DOMAIN|'$EPC_DOMAIN'|g' install/etc/open5gs/smf.yaml
sed -i 's|PCSCF_IP|'$PCSCF_IP'|g' install/etc/open5gs/smf.yaml
sed -i 's|IMS_APN|'$IMS_APN'|g' install/etc/open5gs/smf.yaml

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


N4=192.168
N6=fd84:6aea:c36e:2b
START=103


ourapns=""

for ap in ${APN[@]}
do
	if [[ $ap =~ "(" ]];
	then 
		continue
	fi
	if [[ $ap =~ ")" ]];
	then 
		continue
	fi
	HEXS=`printf '%x\n' "$START"`
        ourapns="${ourapns}      - addr: 192.168.$START.1/24\n        apn: $ap\n        dev: ogstun$START\n      - addr: fd84:6aea:c3$HEXS:2b69::/64\n        apn: $ap\n        dev: ogstun$START\n"
	START=$((START+1))
done
sed -i "s|APNS|$ourapns|" "install/etc/open5gs/smf.yaml"
