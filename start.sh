docker stop serf 2>/dev/null
docker rm serf 2>/dev/null

docker run -d \
  --net=host \
  --name=serf \
  -e "PORT_SCAN=yes" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  rickalm/hashicorp-serf
