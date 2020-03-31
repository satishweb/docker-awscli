IMAGE=satishweb/awscli
PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7
WORKDIR=$(shell pwd)

BASE_TAG:=draft-latest
COMMAND_TAG:=draft-latest
SHELL_TAG:=draft-shell-latest

clean:
	-docker rmi -f $(docker images|grep "${IMAGE}"|awk '{print $$1":"$$2}')

command-image:
	./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${PLATFORMS}" \
	  --work-dir "${WORKDIR}/command" \
	  --git-tag "${COMMAND_TAG}" \
	  --push-images ${EXTRA_BUILD_PARAMS}

shell-image:
	docker pull ${IMAGE}:${BASE_TAG}
	./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${PLATFORMS}" \
	  --work-dir "${WORKDIR}/shell" \
	  --git-tag "${SHELL_TAG}" \
	  --push-images ${EXTRA_BUILD_PARAMS}

all: command-image shell-image
	@# As a dependency we built draft-latest and draft-shell-latest tags
	@# Now we will identify awscli version from the draft-latest image
	@# After that we will create latest tags and aws cli version tags for command and shell both types.
	$(eval AWS_CLI_VER:=$(shell docker run --rm -it ${IMAGE}:${BASE_TAG} --version|awk -F '[ /]' '{ print $$2 }'))
	if [[ ${AWS_CLI_VER} != *.*.* ]]; then \
		echo "Bad AWS cli version: ${AWS_CLI_VER}" && exit 1 ;\
	fi
	@# Lets create latest and aws cli tag for command image
	${MAKE} command-image COMMAND_TAG="${AWS_CLI_VER}" EXTRA_BUILD_PARAMS=--mark-latest
	@# Lets create shell-latest tag for shell image
	${MAKE} shell-image SHELL_TAG="shell-latest"
	@# Lets create aws cli version tag for shell image
	${MAKE} shell-image SHELL_TAG="shell-${AWS_CLI_VER}"
