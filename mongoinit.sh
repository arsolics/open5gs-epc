echo "db.subscribers.remove( { } )" | docker exec -i mongo mongo 100.77.0.2/open5gs --
docker cp sims/sims.json mongo:/mnt/sims.json
docker exec -it mongo mongoimport -h 100.77.0.2 -d open5gs -c subscribers /mnt/sims.json

