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

[ ${#MNC} == 3 ] && IMS_DOMAIN="ims.mnc${MNC}.mcc${MCC}.3gppnetwork.org" || IMS_DOMAIN="ims.mnc0${MNC}.mcc${MCC}.3gppnetwork.org"

mkdir /etc/kamailio_icscf
cp /mnt/icscf/icscf.cfg /etc/kamailio_icscf
cp /mnt/icscf/icscf.xml /etc/kamailio_icscf
cp /mnt/icscf/kamailio_icscf.cfg /etc/kamailio_icscf

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 5;

# Create ICSCF database, populate tables and grant privileges
if [[ -z "`mysql -u root -h ${MYSQL_IP} -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='icscf'" 2>&1`" ]];
then
	mysql -u root -h ${MYSQL_IP} -e "create database icscf;"
	mysql -u root -h ${MYSQL_IP} icscf < /usr/local/src/kamailio/misc/examples/ims/icscf/icscf.sql
	mysql -u root -h ${MYSQL_IP} -e "grant delete,insert,select,update on icscf.* to icscf@$ICSCF_IP identified by 'heslo';"
	mysql -u root -h ${MYSQL_IP} -e "grant delete,insert,select,update on icscf.* to provisioning@$ICSCF_IP identified by 'provi';"
	mysql -u root -h ${MYSQL_IP} -e "GRANT ALL PRIVILEGES ON icscf.* TO 'icscf'@'%' identified by 'heslo';"
	mysql -u root -h ${MYSQL_IP} -e "GRANT ALL PRIVILEGES ON icscf.* TO 'provisioning'@'%' identified by 'provi';"
	mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"

	# Add serving SCSCF entry to ICSCF
	mysql -u root -h ${MYSQL_IP} icscf -e "INSERT INTO nds_trusted_domains VALUES (1,'$IMS_DOMAIN');"
	mysql -u root -h ${MYSQL_IP} icscf -e "INSERT INTO s_cscf VALUES (1,'First and only S-CSCF','sip:scscf.$IMS_DOMAIN:6060');"
	mysql -u root -h ${MYSQL_IP} icscf -e "INSERT INTO s_cscf_capabilities VALUES (1,1,0),(2,1,1);"
fi

sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_icscf/icscf.cfg
sed -i 's|MYSQL_IP|'$MYSQL_IP'|g' /etc/kamailio_icscf/icscf.cfg

sed -i 's|ICSCF_IP|'$ICSCF_IP'|g' /etc/kamailio_icscf/icscf.xml
sed -i 's|IMS_DOMAIN|'$IMS_DOMAIN'|g' /etc/kamailio_icscf/icscf.xml

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
