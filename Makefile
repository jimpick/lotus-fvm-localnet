
all: build

build: build-base

.PHONY: all build run

build-base:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile --progress=plain -t jimpick/lotus-fvm-localnet-base .

run:
	docker rm localnet
	docker run -it --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet
