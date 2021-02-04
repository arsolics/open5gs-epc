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

cp /mnt/fhoss/configurator.sh /opt/OpenIMSCore/FHoSS/deploy
cp /mnt/fhoss/configurator.sh /opt/OpenIMSCore/FHoSS/scripts
cp /mnt/fhoss/configurator.sh /opt/OpenIMSCore/FHoSS/config

cd /opt/OpenIMSCore/FHoSS/deploy && ./configurator.sh ${IMS_DOMAIN} ${FHOSS_IP}
sed -i 's|open-ims.org|'$IMS_DOMAIN'|g' /opt/OpenIMSCore/FHoSS/deploy/webapps/hss.web.console/WEB-INF/web.xml
sed -i 's|'$FHOSS_IP'|'$MYSQL_IP'|g' /opt/OpenIMSCore/FHoSS/deploy/hibernate.properties
cd /opt/OpenIMSCore/FHoSS/scripts && ./configurator.sh ${IMS_DOMAIN} ${FHOSS_IP}
cd /opt/OpenIMSCore/FHoSS/config && ./configurator.sh ${IMS_DOMAIN} ${FHOSS_IP}
sed -i 's|open-ims.org|'$IMS_DOMAIN'|g' /opt/OpenIMSCore/FHoSS/src-web/WEB-INF/web.xml

while ! mysqladmin ping -h ${MYSQL_IP} --silent; do
	sleep 5;
done

# Sleep until permissions are set
sleep 5;

# Create FHoSS database, populate tables and grant privileges
if [[ -z "`mysql -u root -h ${MYSQL_IP} -qfsBe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='hss_db'" 2>&1`" ]];
then
	mysql -u root -h ${MYSQL_IP} -e "create database hss_db;"
	mysql -u root -h ${MYSQL_IP} hss_db < /opt/OpenIMSCore/FHoSS/scripts/hss_db.sql
	mysql -u root -h ${MYSQL_IP} hss_db < /opt/OpenIMSCore/FHoSS/scripts/userdata.sql
	mysql -u root -h ${MYSQL_IP} -e "grant delete,insert,select,update on hss_db.* to hss@$FHOSS_IP identified by 'hss';"
	mysql -u root -h ${MYSQL_IP} -e "grant delete,insert,select,update on hss_db.* to hss@'%' identified by 'hss';"
	mysql -u root -h ${MYSQL_IP} -e "FLUSH PRIVILEGES;"
fi

# Sync docker time
#ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

cp /mnt/fhoss/hss.sh /
cd / && ./hss.sh
