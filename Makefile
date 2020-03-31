IMAGE=satishweb/awscli
PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7
WORKDIR=$(shell pwd)

BASE_TAG:=draft-latest
COMMAND_TAGS:=draft-latest
SHELL_TAGS:=draft-shell-latest

clean:
	-docker rmi -f $(docker images|grep "${IMAGE}"|awk '{print $$1":"$$2}')

command-image:
	./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${PLATFORMS}" \
	  --work-dir "${WORKDIR}/command" \
	  --git-tag "${COMMAND_TAGS}" \
	  --push-images ${EXTRA_BUILD_PARAMS}

shell-image: command-image
	docker pull ${IMAGE}:${BASE_TAG}
	./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${PLATFORMS}" \
	  --work-dir "${WORKDIR}/shell" \
	  --git-tag "${SHELL_TAGS}" \
	  --push-images ${EXTRA_BUILD_PARAMS}

all: command-image shell-image
	# Create Docker image tags and push
	$(eval AWS_CLI_VER:=$(shell docker run --rm -it ${IMAGE}:${BASE_TAG} --version|awk -F '[ /]' '{ print $$2 }'))
	if [ ${AWS_CLI_VER} != *.*.* ]; then \
		echo "Bad AWS cli version: ${AWS_CLI_VER}" ;\
		exit 1 ;\
	fi
	${MAKE} command-image COMMAND_TAGS="latest ${AWS_CLI_VER}" EXTRA_BUILD_PARAMS=--mark-latest
	${MAKE} shell-image SHELL_TAGS="shell-latest shell-${AWS_CLI_VER}" EXTRA_BUILD_PARAMS=--mark-latest
