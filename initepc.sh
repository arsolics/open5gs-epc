urpmi --force docker docker-compose 
docker pull arsolics/open5gs:1618491821
docker tag arsolics/open5gs:1618491821 docker_open5gs:latest
docker-compose up -d
bash mongoinit.sh
bash yate-sdr-fix.sh
