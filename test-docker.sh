docker_ip=$(ip -o addr show docker0 | grep "inet " | sed -e 's/^.*inet //' | cut -d/ -f1)

docker rm -f serf 2>/dev/null
docker rm -f serf-bridge 2>/dev/null

/bin/true && docker run -d \
  --net=host \
  --name=serf \
  -e "DEBUG=yes" \
  -e "PORT_SCAN=yes" \
  -e "PORT_SCAN_MASK=subnet" \
  rickalm/hashicorp-serf \
  && docker exec -it serf /bin/bash

/bin/true && docker run -d \
  --net=bridge \
  --name=serf-bridge \
  -e "DEBUG=yes" \
  -p 41000:7946 \
  -p 41000:7946/udp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  rickalm/hashicorp-serf \
  && docker exec -it serf-bridge /bin/bash
