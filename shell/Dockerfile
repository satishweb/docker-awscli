#!/bin/bash
# Author: Satish Gaikwad <satish@satishweb.com>
#
# The image opens a shell, the command of aws is in it. It is made from the
# image with the command, so the command is the same in both of them.
#
# The image of the command is given with the argument, the local build uses
# the tag the Makefile builds, the CI build passes the tag it has just built.
ARG BASE_IMAGE=satishweb/awscli:draft-latest
FROM ${BASE_IMAGE}
LABEL maintainer="Satish Gaikwad <satish@satishweb.com>"

USER root

COPY --chmod=0755 shell/entrypoint.sh /opt/entrypoint.sh

# The container runs with the same user as the image it is made from.
USER ubuntu
WORKDIR /home/ubuntu

# The entrypoint runs the command that is given to the container.
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash"]
