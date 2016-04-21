FROM phusion/baseimage:0.9.15
MAINTAINER rickalm@aol.com

# Environmental variables
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update -qq \
	&& apt-get install unzip -y \
	&& apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Disable sshd, cron and syslog-ng service
#
RUN rm -rf /etc/service/sshd /etc/service/syslog-ng /etc/service/cron

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
ADD bin/serf /etc/service/serf

# Cleanup 

# Leverage the baseimage-docker init system
#
CMD ["/sbin/my_init", "--quiet"]
