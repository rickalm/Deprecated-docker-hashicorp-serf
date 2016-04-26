docker ps | grep serf | cut -b1-20 | xargs docker rm -f
