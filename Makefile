
all: build

build:
	docker build -t jimpick/lotus-fvm-localnet .

run:
	docker rm localnet
	docker run -it --entrypoint /bin/bash --name localnet jimpick/lotus-fvm-localnet
