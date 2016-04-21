docker_ip=$(ip -o addr show docker0 | grep "inet " | sed -e 's/^.*inet //' | cut -d/ -f1)

docker rm -f serf 2>/dev/null
docker rm -f serf-bridge 2>/dev/null

/bin/false && docker run -d \
  --net=host \
  --name=serf \
  -e "PORT_SCAN=yes" \
  -e "RRPC_IP=${docker_ip}" \
  rickalm/hashicorp-serf \
  && docker exec -it serf /bin/bash

/bin/true && docker run -d \
  --net=bridge \
  --name=serf-bridge \
  -p 41000:7946 \
  -p 41000:7946/udp \
  -e "JOIN_LIST=$(hostname -i)" \
  -e "ADVERTISE_IP=$(hostname -i|awk '{print $1}')" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  rickalm/hashicorp-serf \
  && docker exec -it serf-bridge /bin/bash
