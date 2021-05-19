urpmi --force docker docker-compose 
docker pull arsolics/open5gs:1618491821
docker tag arsolics/open5gs:1618491821 docker_open5gs:latest
docker-compose up -d
docker cp sims/sims.json mongo:/mnt/sims.json
#docker exec -it mongo mongoimport -h 100.77.0.2 -d open5gs -c subscribers /mnt/sims.json
bash mongoinit.sh
bash yate-sdr-fix.sh
