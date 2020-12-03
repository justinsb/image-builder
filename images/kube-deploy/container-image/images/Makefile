PLATFORM=arm64 # amd64
# Note: for crossbuild you may need to install qemu-user-static or similar

.PHONY: all
all: buster-qemu buster-aws

.PHONY: builders
builders:
	docker build -t builder-${PLATFORM} --platform ${PLATFORM} --pull builder/

.PHONY: buster-base
buster-base:
	DOCKER_BUILDKIT=1 docker build --build-arg BUILDER_IMAGE=builder-${PLATFORM} -t buster-base-common-${PLATFORM} -f buster-base/Dockerfile.common buster-base/
	DOCKER_BUILDKIT=1 docker build --build-arg BASE_IMAGE=buster-base-common-${PLATFORM} -t buster-base-${PLATFORM} -f buster-base/Dockerfile.${PLATFORM} buster-base/

.PHONY: buster-qemu
buster-qemu: buster-base
	DOCKER_BUILDKIT=1 docker build --build-arg BASE_IMAGE=buster-base-${PLATFORM} -t buster-qemu-${PLATFORM} buster-qemu/

.PHONY: buster-aws
buster-aws: buster-base
	DOCKER_BUILDKIT=1 docker build -t buster-aws buster-aws/

.PHONY: buster-gce
buster-gce: buster-base
	DOCKER_BUILDKIT=1 docker build -t buster-gce buster-gce/
