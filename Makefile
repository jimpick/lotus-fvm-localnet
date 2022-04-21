
all: build

build:
	DOCKER_BUILDKIT=1 docker build --progress=plain -t jimpick/lotus-fvm-localnet .

run:
	docker rm localnet
	docker run -it --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet
