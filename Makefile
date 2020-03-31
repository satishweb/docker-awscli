IMAGE=satishweb/awscli
PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7
WORKDIR=$(shell pwd)

clean:
	-docker rmi -f $(docker images|grep "${IMAGE}"|awk '{print $$1":"$$2}')

command-image:
ifndef TAGS
	TAGS=latest
endif
	./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${PLATFORMS}" \
	  --work-dir "${WORKDIR}" \
	  --git-tag "${TAGS}" \
	  --push-images ${EXTRA_BUILD_PARAMS}

shell-image: command-image
ifndef TAGS
	BASE_TAG=draft-latest
	TAGS=draft-shell-latest
endif
	docker pull ${IMAGE}:${BASE_TAG}
	./build.sh \
	  --image-name "${IMAGE}" \
	  --platforms "${PLATFORMS}" \
	  --work-dir "${WORKDIR}" \
	  --git-tag "${TAGS}" \
	  --push-images ${EXTRA_BUILD_PARAMS}

git-tag-prepare:
	docker pull ${IMAGE}:draft-latest
	docker pull ${IMAGE}:draft-shell-latest
	set -e ; \
	if [ ${AWS_CLI_VER} != *.*.* ]; then \
		echo "Bad AWS cli version: ${AWS_CLI_VER}" ;\
		exit 1 ;\
	fi

all: command-image shell-image
	# Create Docker image tags and push
	AWS_CLI_VER=$(shell docker run --rm -it ${IMAGE}:draft-latest --version|awk -F '[ /]' '{ print $$2 }')
	${MAKE} command-image TAGS="latest ${AWS_CLI_VER}" EXTRA_BUILD_PARAMS=--mark-latest
	${MAKE} shell-image TAGS="shell-latest shell-${AWS_CLI_VER}" EXTRA_BUILD_PARAMS=--mark-latest
