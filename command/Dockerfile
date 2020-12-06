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
RUN apt-get -y update \
	# Lets install base packages required for awscli + jq
	&& apt-get install -y python3 python3-pip ca-certificates locales jq\
	# Lets setup locale for this shell
	&& locale-gen en_US.UTF-8 \
	&& export LC_ALL=en_US.UTF-8 \
	&& export LANG=en_US.UTF-8 \
	# Lets save locale variables inside /etc/profile for command/shell that run inside container later
	&& echo "export LC_ALL=en_US.UTF-8">>/etc/profile \
	&& echo "export LANG=en_US.UTF-8">>/etc/profile \
	# Lets install awscli latest version
	&& pip3 install awscli \
	# Lets uninstall build tools that are no longer required for awscli.
	# Note: If you intend to run pip command inside container later, it will not work without build-essential packages.
	# If you intend to upgrade awscli package, please pull latest awscli docker image from docker hub using docker pull command.
	&& apt-get -y purge build-essential \
	# Remove auto installed unwanted packages post build-essential package bundle removal
	&& apt-get -qy autoremove --purge \
	# Removing devel packages, few MBs less :)
	&& dpkg --purge libpython-all-dev libpython-dev python-all-dev python-pip-whl python3-pip python3-wheel python3-setuptools python3-dev \
        # Lets remove all downloaded packages from cache. This reduces image size significantly.
	# Note: Docker should remove it on its own however no harm having this command here
	&& rm -rf /var/cache/apt/archives/*deb \
	# Lets create the entrypoint script to handle switch between invoking of default bash shell and aws command execution. 
	# We will launch bash shell if there is/are no input parameter(s)/command given to docker run command
	# We will run aws command by default if CMD is not called by docker run command.
	&& echo '#!/bin/bash'>/opt/entrypoint.sh \
	# If first parameter is "/bin/bash" then run /bin/bash shell or execute aws command with given parameters.
	&& echo 'set -e && if [[ "$1" == "/bin/bash" ]]; then /bin/bash ; else exec "/usr/local/bin/aws" $@ ; fi' >>/opt/entrypoint.sh \
	# Lets make entrypoint script executable
	&& chmod +x /opt/entrypoint.sh

# This command had to be separate since docker build has problem with dpkg --force-depends command for determining exit status check.
RUN cd /tmp; \
	# awscli help pages use groff command for printing on screen.
	# Installing groff with apt-get installs way too many unwanted packages making image size bigger
	# Installing groff manually with only required libs will keep image size reasonable
	apt-get download groff groff-base && dpkg --force-depends -i *.deb ; rm -rf /tmp/*deb ;\
	# Install missing dependancies for existing packages.
	apt-get -f install ; \
	# Install ssh commands.
	apt-get install sshcommand ; \
	# Docker build command fails due to dpkg dependancy errors, we need to ignore errors here hence we exit with code 0 to let docker think this RUN was successful.
	exit 0

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
