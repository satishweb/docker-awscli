#!/bin/bash
# Ubuntu + awscli Docker image
# Type: Command Based (Direct command execution upon container launch)
# Use: Manual commandline purpose
# Author: Satish Gaikwad <satish@satishweb.com>

# We will always take latest stable ubuntu docker image as base image
FROM ubuntu
MAINTAINER Satish Gaikwad <satish@satishweb.com>

# We are going to put all commands inside single RUN to generate a single layer of image.
# This helps in keeping image size smaller as we clean unwanted files in same RUN command.
# There is nothing tangible in these commands that can be used in new Dockerfiles that depends on this image.
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
        && apt-get -y update \
	# Lets install base packages required for awscli + jq
	&& apt-get install -y awscli \
	&& apt-get -qy autoremove --purge \
	&& rm -rf /var/cache/apt/archives/*deb \
	# Lets create the entrypoint script to handle switch between invoking of default bash shell and aws command execution. 
	# We will launch bash shell if there is/are no input parameter(s)/command given to docker run command
	# We will run aws command by default if CMD is not called by docker run command.
	&& echo '#!/bin/bash'>/opt/entrypoint.sh \
	# If first parameter is "/bin/bash" then run /bin/bash shell or execute aws command with given parameters.
	&& echo 'set -e && if [[ "$1" == "/bin/bash" ]]; then /bin/bash ; else exec "/usr/local/bin/aws" $@ ; fi' >>/opt/entrypoint.sh \
	# Lets make entrypoint script executable
	&& chmod +x /opt/entrypoint.sh

# Lets define entrypoint to execute the entrypoint script.
# Entrypoint gets invoked unless docker run command has entrypoint override.
# Entrypoint invoking options :-
#	1. Docker run command without any parameters: Entrypoint calls entrypoint script with CMD arguments.
#		Eexecuted Command: /opt/entrypoint.sh /bin/bash
#	2. Docker run command with parameter(s): Entrypoint calls entrypoint script with given arguments and ignores CMD command/arguments
#		Executed Command: /opt/entrypoint.sh <docker run command given arguments> (internally script runs: /usr/local/bin/aws <given arguments> unless argument is /bin/bash)
ENTRYPOINT ["/opt/entrypoint.sh"]

# Default argument to pass to entrypoint if docker run command do not pass any arguments.
CMD ["/bin/bash"]
