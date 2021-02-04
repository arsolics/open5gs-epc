


### ya dee dah:


* edit and copy daemon.json to /etc/docker/ (choose your address space wisely)
* edit .env file accordingly
* run
```bash
source .env
docker-compose build
docker-compose up -d
```

the application will be accessible via VPN on https://$WEBUI_IP/ (check the .env file for the WEBUI )
username `admin` password `1423`

* to generate a vpn connection creds file enter the openvpn-as container as it follows
```bash
docker-compose exec openvpn-as easy-rsa build-client-full CLIENTNAME nopass
docker-compose exec openvpn-as ovpn_getclient_all
docker-compose exec openvpn-as /etc/openvpn/clients/CLIENTNAME/CLIENTNAME-combined.ovpn
```
Deliver this file to the client.
* to revoke a client use
```bash
docker-compose exec openvpn-as ovpn_revokeclient CLIENTNAME
```
* reinitializing the VPN system entirely
```bash
docker-compose stop openvpn-as ; docker-compose rm -v  openvpn-as ; docker volume rm docker_open5gs_ovpndata ; docker-compose up -d
```
