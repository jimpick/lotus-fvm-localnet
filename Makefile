
all: build

build: build-base

.PHONY: all build build-base build-ready run-base run-ready run-base-root

build-base:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile-base --progress=plain -t jimpick/lotus-fvm-localnet-base .

build-ready:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile-ready --progress=plain -t jimpick/lotus-fvm-localnet-ready .

build-lite:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile-lite --progress=plain -t jimpick/lotus-fvm-localnet-lite .

build-python:
	DOCKER_BUILDKIT=1 docker build -f Dockerfile-python --progress=plain -t jimpick/lotus-fvm-localnet-python .

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

run-lite:
	-docker stop localnet
	-docker rm localnet
	docker run -it --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet-lite

run-python:
	-docker stop localnet
	-docker rm localnet
	docker run -it --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet-python
