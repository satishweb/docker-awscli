#!/bin/bash
# Ubuntu + awscli Docker image

FROM ubuntu
MAINTAINER Satish Gaikwad <satish@satishweb.com>

RUN apt-get -y update \
    && export NOTVISIBLE="in users profile" \
	&& apt-get install -y python python-pip ca-certificates \
	&& locale-gen en_US.UTF-8 \
	&& pip install awscli \
	&& apt-get -y purge build-essential \
	&& apt-get -qy autoremove --purge \
	&& dpkg --list |grep "^rc" | cut -d " " -f 3 | xargs sudo dpkg --purge \
	&& rm -rf /var/cache/apt/archives/*deb
ENTRYPOINT ["/usr/local/bin/aws"]
CMD ["/usr/local/bin/aws"]