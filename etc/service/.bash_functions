#! /bin/bash

log_dir=${log_dir:-/var/log}
docker_sock=${docker_sock:-/var/run/docker.sock}

# Start Serf
if [ -n "${DEBUG}" ]; then
  log_level=debug
  #exec 1>&-
  #exec 2>&-
  #exec 1>>${log_dir}/${appname}.stdout
  #exec 2>>${log_dir}/${appname}.stderr
  #set -x
fi

node_name=${NODE_NAME:-$(hostname -s)}

get_docker_port_map() {
  local port_to_map=${1}
  local reply=${1}

  # If we are in BRIDGE mode, try to translate port
  #
  if [ -z "$(ip -o link show dev docker0 2>/dev/null)" ]; then 

    # If the docker socket exposed to us (useful for bridge mode) then try to discover the external port this container is listening on
    #
    if [ -S ${docker_sock} ]; then

      # Use docker container info to find out the mapped port for the bind_port
      #
      local json=$( echo -e "GET /containers/$(hostname -s)/json HTTP/1.1\\n\\n" | socat unix-connect:${docker_sock} STDIO | grep '^[\[{]' )

      # If we got an answer extract the needed value
      #
      if [ -n "${json}" ]; then
        local answer=$( echo ${json} | jq .NetworkSettings.Ports[\"${port_to_map}/tcp\"][].HostPort | sed -e 's/^"//' -e 's/"$//' )
	answer=${answer/null/}
        reply=${answer:-${reply}}
      fi
    fi
  fi
 
  echo ${reply}
}

get_docker_port_bind_map() {
  local port_to_map=${1}
  local reply=$(get_docker_host_map)

  # If we are in BRIDGE mode, try to translate port
  #
  if [ -z "$(ip -o link show dev docker0 2>/dev/null)" ]; then 

    # If the docker socket exposed to us (useful for bridge mode) then try to discover the external port this container is listening on
    #
    if [ -S ${docker_sock} ]; then

      # Use docker container info to find out the mapped port for the bind_port
      #
      local json=$( echo -e "GET /containers/$(hostname -s)/json HTTP/1.1\\n\\n" | socat unix-connect:${docker_sock} STDIO | grep '^[\[{]' )

      # If we got an answer extract the needed value
      #
      if [ -n "${json}" ]; then
        local answer=$( echo ${json} | jq .NetworkSettings.Ports[\"${port_to_map}/tcp\"][].HostIp | sed -e 's/^"//' -e 's/"$//' )
	answer=${answer/null/}
	answer=${answer/0.0.0.0/}
        reply=${answer:-${reply}}
      fi
    fi
  fi

  echo ${reply}
}

get_docker_host_map() {
  local reply=$(hostname -i)

  # If we are in BRIDGE mode, try to translate port
  #
  if [ -z "$(ip -o link show dev docker0 2>/dev/null)" ]; then 

    # If the docker socket exposed to us (useful for bridge mode) then try to discover the external port this container is listening on
    #
    if [ -S ${docker_sock} ]; then

      # Use docker info to figure out the docker host's name and then use ping to transform to the IP address
      #
      local json=$( echo -e "GET /info HTTP/1.1\\n\\n" | socat unix-connect:${docker_sock} STDIO | grep '^[\[{]' )
      if [ -n "${json}" ]; then
        echo ${json} | jq . >>${log_dir}/serf.log
        local docker_hostname=$( echo ${json} | jq .Name | sed -e 's/^"//' -e 's/"$//' )
        local answer=$(ping -n -c 1 -w 1 ${docker_hostname} | grep ^PING | cut -d\( -f 2 | cut -d\) -f1)
        reply=${answer:-${reply}}
      fi
    fi
  fi

  echo ${reply}
}


port_scan_network() {
  local reply

  # use nmap to find our peers within our network
  # keep expanding the netmask till we find a peer that might want to talk to us
  # netmask cannot be wider than 16
  #
  local port_to_scan=${1}
  local port_scan_mask=${2}
  local device
  local base
  local mask

  # Only calculate netmask if we are in HOST mode
  #
  if [ -n "$(ip -o link show dev docker0 2>/dev/null)" ]; then 
    device=$(ip -o route get 8.8.8.8 | sed -e 's/^.*dev //' -e 's/ .*//')
    base=$(ip addr show dev ${device} | grep "inet " | awk '{print $2}' | cut -d/ -f1)
    mask=$(ip addr show dev ${device} | grep "inet " | awk '{print $2}' | cut -d/ -f2)

  # Otherwise default to 24 if not specified
  #
  else
    mask=${port_scan_mask:-24}${port_scan_mask}

  fi

  # if port_scan_mask is "subnet", set it to the discovered mask for this host
  #	
  [ "${port_scan_mask}" == "subnet" ] && port_scan_mask=${mask}

  # if port_scan_mask is set, use it as the widest mask, otherwise its set to 16
  #
  mask_limit=${port_scan_mask:-${mask}}

  # If mask_limit is wider than 16 reset the limit
  #
  [ "${mask_limit}" -lt 16 ] && mask_limit=16

  # if the starting mask is wider than the mask limit
  # change the starting mask to the mask limit so it at least runs once
  #
  [ "${mask}" -lt "${mask_limit}" ] && mask=${mask_limit}

  while [ -z "${reply}" -a ${mask} -ge ${mask_limit} ]; do
    for host in $( nmap --open --send-ip --unprivileged -n -p${port_to_scan} -oG - ${base}/${mask} \
    | grep "^Host" | grep ${port_to_scan} | awk '{print $2}' ); do
      reply="${reply}${reply:+ }${host}:${port_to_scan}" 
    done
    mask=$((mask-2))
  done

  echo ${reply}
}

