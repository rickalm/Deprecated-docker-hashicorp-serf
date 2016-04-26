docker ps | grep serf | cut -b1-20 | xargs docker rm -f

/bin/true && docker run -d \
  --net=host \
  --name=serf-host \
  -e "DEBUG=yes" \
  -e "PORT_SCAN=yes" \
  -e "SERF_MASTER=yes" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  rickalm/hashicorp-serf

/bin/true && docker run -d \
  --net=bridge \
  --name=serf-bridge \
  -e "DEBUG=yes" \
  -p 41000:7946 \
  -p 41000:7946/udp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  rickalm/hashicorp-serf

/bin/true && docker run -d \
  --net=host \
  --name=serf-host2 \
  -e "DEBUG=yes" \
  -e "PORT_SCAN=yes" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  rickalm/hashicorp-serf

/bin/true && docker exec -it serf-host /bin/bash
/bin/true && docker exec -it serf-bridge /bin/bash
