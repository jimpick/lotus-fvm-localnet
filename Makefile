
all: build

build: build-base

.PHONY: all build build-base build-ready run

build-base:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile-base --progress=plain -t jimpick/lotus-fvm-localnet-base .

build-ready:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile-ready --progress=plain -t jimpick/lotus-fvm-localnet-ready .

run:
	docker rm localnet
	docker run -it --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet
