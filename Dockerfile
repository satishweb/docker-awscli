#!/bin/bash
# Ubuntu latest

FROM ubuntu
MAINTAINER Satish Gaikwad <satish@satishweb.com>

RUN apt-get -y update \
    && export NOTVISIBLE="in users profile" \
	&& apt-get -y upgrade \
	&& apt-get install -y python python-pip ca-certificates \
	&& locale-gen en_US.UTF-8 \
	&& pip install awscli \
	&& rm -rf /var/cache/apt/archives/*deb

CMD ["/usr/bin/supervisord"]