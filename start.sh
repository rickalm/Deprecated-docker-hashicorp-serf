. stop-docker.sh

docker run -d \
  --net=host \
  --name=serf \
  -e "PORT_SCAN=yes" \
  -e "SERF_MASTER=yes" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  rickalm/hashicorp-serf

