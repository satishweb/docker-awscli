# Author: Satish Gaikwad <satish@satishweb.com>
# The image has the command of the aws command line interface.
#
# Type: Command Based (Direct command execution upon container launch)
# Use: Manual commandline purpose
FROM ubuntu:24.04
LABEL maintainer="Satish Gaikwad <satish@satishweb.com>"

ARG AWSCLI_VERSION=1.46.2

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# The base packages of the image. The shell of the user and the tools to
# work with the output of the command are in it.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    groff-base \
    jq \
    locales \
    openssh-client \
    python3 \
    python3-pip \
    python3-venv \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# The command is installed in its own environment, the packages of the
# system python are not touched by it. The version of the command is fixed,
# the image is the same with every build.
RUN python3 -m venv /opt/aws-cli \
    && /opt/aws-cli/bin/pip install --no-cache-dir "awscli==${AWSCLI_VERSION}" \
    && ln -s /opt/aws-cli/bin/aws /usr/local/bin/aws \
    && aws --version

# The command does not need the rights of the root, the container runs with
# the user that is in the base image.
USER ubuntu
WORKDIR /home/ubuntu

COPY --chmod=0755 command/entrypoint.sh /opt/entrypoint.sh

# The entrypoint starts the shell of the user when there is no argument, and
# it runs the command of aws with the arguments otherwise.
ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash"]
