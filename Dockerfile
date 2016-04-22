FROM phusion/baseimage:latest
MAINTAINER rickalm@aol.com

# Environmental variables
#
ENV DEBIAN_FRONTEND noninteractive

# Leverage the baseimage-docker init system
#
CMD ["/sbin/my_init", "--quiet"]

# Tell docker to put volatile directories onto a seperate volume(s)
#
VOLUME /var/log

# Install dependencies
#
RUN apt-get update -qq \
	&& apt-get upgrade -y \
	&& apt-get install unzip nmap socat jq traceroute -y \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Disable sshd, cron and syslog-ng service
#
RUN rm -rf /etc/service/sshd /etc/service/syslog-ng /etc/service/cron /etc/service/syslog-forwarder

# Install Serf
#
RUN cd /tmp \
	&& export SERF_VER=0.6.3 \
	&& curl -so package https://releases.hashicorp.com/serf/${SERF_VER}/serf_${SERF_VER}_linux_amd64.zip \
	&& unzip package -d /usr/bin/ \
	&& rm package \
	&& adduser --system --disabled-password --no-create-home --quiet --force-badname --shell /bin/bash --group serf \
    	&& echo "serf ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99_serf \
	&& chmod 0440 /etc/sudoers.d/99_serf

# Setup start scripts for services
#
ADD etc /etc
RUN curl https://github.com/rickalm/docker-tools/raw/master/.docker_functions -so etc/.docker_functions

