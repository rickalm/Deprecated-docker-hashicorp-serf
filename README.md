= Docker container for Hashicorp Serf service

== Usage

This can be used to serve or request data in a cluster.

The main use case (vs a load balancer) is to use a bootstrap node to organize a cluster and then allow the bootstrap node to withdraw

== Deployment

docker run -d --host=net \
	-e "VAR=value" \
	-v "/path/to/file/script.sh:/etc/serf/handlers/" \
	rickalm/docker-hashicorp-serf


Supported Env values are

- NODE_NAME	alternative name to use for the node [ default $(hostname -s) ]
- BIND_PORT	Which port to use for the instance [ default 7946 ]
- HOST_IP	If you need to advertise a different IP address [ default $(hostname -i) ]
- JOIN_LIST	a comma deliminated list of Serf nodes to join host1,host2:port,host3:port
