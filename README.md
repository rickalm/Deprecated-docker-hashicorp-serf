# Docker container for Hashicorp Serf service

## Usage

This can be used to serve or request data in a cluster.

The main use case (vs a load balancer) is to use a bootstrap node to organize a cluster and then allow the bootstrap node to withdraw

## Deployment

docker run -d --host=net \
	-e "VAR=value" \
	-v "/path/to/file/script.sh:/etc/serf/handlers/<handler-name>" \
	rickalm/docker-hashicorp-serf


Supported Env values are

- NODE_NAME	alternative name to use for the node [ default $(hostname -s) ]
- BIND_PORT	Which port to use for the instance [ default 7946 ]
- HOST_IP	If you need to advertise a different IP address [ default $(hostname -i) ]
- JOIN_LIST	a comma deliminated list of Serf nodes to join host1,host2:port,host3:port

Supported Handlers

- member-join			One or more members have joined the cluster.
- member-leave			One or more members have gracefully left the cluster.
- member-failed			One or more members have failed, meaning that they didn't properly respond to ping requests.
- member-update			One or more members have updated, likely to update the associated tags
- member-reap			Serf has removed one or more members from it's list of members. This means a failed node exceeded the reconnect_timeout, or a left node reached the tombstone_timeout.

- query-* 			called when a query is called
- event-* 			called when a event is dispatched
