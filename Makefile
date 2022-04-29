
all: build

build: build-base

.PHONY: all build build-base build-ready run-base run-ready run-base-root

build-base:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile-base --progress=plain -t jimpick/lotus-fvm-localnet-base .

build-ready:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile-ready --progress=plain -t jimpick/lotus-fvm-localnet-ready .

run-base:
	-docker stop localnet
	-docker rm localnet
	docker run -it --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet-base

run-base-root:
	-docker stop localnet
	-docker rm localnet
	docker run -it --user=0 --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet-base

run-ready:
	-docker stop localnet
	-docker rm localnet
	docker run -it --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet-ready
