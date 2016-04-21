# Docker container for Hashicorp Serf service

## Usage

This can be used to serve or request data in a cluster.

The main use case (vs a load balancer) is to use a bootstrap node to organize a cluster and then allow the bootstrap node to withdraw

## Deployment

As the main serf agent on a host
```
docker run -d \
	--host=net \
	-e "VAR=value" \
	-v "/path/to/file/script.sh:/etc/serf/handlers/<handler-name>" \
	rickalm/hashicorp-serf
```

For running inside a BRIDGE'ed container (mainly when this container is used as your FROM in your own docker project)

```
docker run -d \
  --host=bridge \
	-e "VAR=value" \
	-p "xxxxx:7946/tcp" \
	-p "xxxxx:7946/udp" \
  -v /var/run/docker.sock:/var/run/docker.sock \
	rickalm/docker-hashicorp-serf
```

Supported Env values are

```
- NODE_NAME	    	alternative name to use for the node [ default $(hostname -s) ]
- DEBUG		       	if set, sets --log-level=debug for serf agent, and turns on logging for sv start script

- RPC_IP	      	Which ip to bind the rpc listener on [ default 127.0.0.1 ]
- RPC_PORT	    	Which port to use for the rpc listener [ default 7373 ]

- BIND_IP	      	Which ip to bind the listener on [ default 0.0.0.0 ]
- BIND_PORT   		Which port to use for the instance [ default 7946 ]

- ADVERTISE_IP		If you need to advertise a different IP address [ default $(hostname -i) ]
- ADVERTISE_PORT	If you need to advertise a different tcp port [ default ${BIND_PORT} ]

- PORT_SCAN   		for --net=host containers will use nmap to find neighbors on the same subnet at the host if set to any value
- PORT_SCAN_MASK	when PORT_SCAN is active will override the subnet mask and set to this value [ range 16-32 ]

- JOIN_LIST    		a comma deliminated list of Serf nodes to join host1,host2:port,host3:port
```

Mapping the docker NATted port

If the docker socket is made availible to the container, then it will use that to determine the port mappings in use for the Gossip Protocol. Docker does not yet have the ability to auto-map ports of both protocols (tcp/udp) automatically to the same ephemeral port on the host so you must also specify the port mappings yourself

Supported Handlers

```
- member-join     One or more members have joined the cluster.
- member-leave    One or more members have gracefully left the cluster.
- member-failed   One or more members have failed, meaning that they didn't properly respond to ping requests.
- member-update   One or more members have updated, likely to update the associated tags
- member-reap     Serf has removed one or more members from it's list of members.
                  This means a failed node exceeded the reconnect_timeout, or a left node reached the tombstone_timeout.

- query-*         called when a query is called
- event-*         called when a event is dispatched
```

