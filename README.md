lotus-fvm-localnet
===

Builds a container image with a development branch of Lotus (experimental/fvm-m2)
for running a localnet in a container for FVM experimentation.

Here are instructions on how to manually create a local network. This image
automates almost all of these steps:

* https://lotus.filecoin.io/developers/local-network/

This is the branch of Lotus with experimental FVM "smart contract" support:

* https://github.com/filecoin-project/lotus/tree/experimental/fvm-m2

# Built images

The "lite" image is an image based on Ubuntu with just the Lotus binaries
and a bootstrapped chain + proofs.

* Docker Image: https://github.com/jimpick/lotus-fvm-localnet/pkgs/container/lotus-fvm-localnet-lite

For information about the intermediate Docker images used in the build, see
the "Building Images" section below.

# Usage: Docker

Run the node:

```
docker run -i -t --rm --name lotus-fvm-localnet ghcr.io/jimpick/lotus-fvm-localnet-lite:latest lotus daemon --lotus-make-genesis=devgen.car --genesis-template=localnet.json --bootstrap=false
```

In another terminal, run the miner:

```
docker exec -i -t lotus-fvm-localnet lotus-miner run --nosync
```

Watch the chain progress:

```
docker exec -it lotus-fvm-localnet watch lotus chain list --count=3
```

It's a really heavy Ubuntu-based image with the full source and lots of tools, eg. `tmux`. You can use additional Docker
options to expose ports to your development host, etc.

# Usage: Kubernetes

Here's a pod spec that will run two containers - one for the node and another for the miner:

```
apiVersion: v1
kind: Pod
metadata:
  name: lotus-fvm-localnet
spec:
  restartPolicy: Always
  containers:
  - name: node
    image: ghcr.io/jimpick/lotus-fvm-localnet-lite@latest
    command: [ bash, -c ]
    args:
      - |
        lotus daemon --lotus-make-genesis=devgen.car --genesis-template=localnet.json --bootstrap=false
    tty: true
  - name: miner
    image: ghcr.io/jimpick/lotus-fvm-localnet-lite@latest
    command: [ bash, -c ]
    args:
      - |
        lotus-miner run --nosync
    tty: true
  securityContext:
    fsGroup: 1000
    fsGroupChangePolicy: "OnRootMismatch"
```

This just uses ephemeral storage on the root overlay filesystem, which will be lost after
the pod is terminated.


# Example Actors

These should work with this localnet.

* https://github.com/raulk/fil-hello-world-actor
* https://github.com/jimpick/fvm-hanoi-actor-1

# Building Images

Because the Docker image takes a very long time to build, it is built in
a number of stages using GitHub Actions.

## base

This image has a full Ubuntu development setup with Go, Rust and a built version of Lotus
along with the source code. Heavy!

The version of Lotus which is built is checked into the top level of this repo as a git submodule.

* Action: https://github.com/jimpick/lotus-fvm-localnet/actions/workflows/container-base.yml
* Dockerfile: https://github.com/jimpick/lotus-fvm-localnet/blob/main/Dockerfile-base
* Package: https://github.com/jimpick/lotus-fvm-localnet/pkgs/container/lotus-fvm-localnet-base

## ready

This image adds a bootstrapped chain and proof parameter files to the "base" image. Heavy!

* Action: https://github.com/jimpick/lotus-fvm-localnet/actions/workflows/container-ready.yml
* Dockerfile: https://github.com/jimpick/lotus-fvm-localnet/blob/main/Dockerfile-ready
* Package: https://github.com/jimpick/lotus-fvm-localnet/pkgs/container/lotus-fvm-localnet-ready

## lite

This image has a non-developer install of Ubuntu plus the compiled Lotus binaries
and the bootstrapped chain and proof parameter files from the "ready" image.

* Action: https://github.com/jimpick/lotus-fvm-localnet/actions/workflows/container-lite.yml
* Dockerfile: https://github.com/jimpick/lotus-fvm-localnet/blob/main/Dockerfile-lite
* Package: https://github.com/jimpick/lotus-fvm-localnet/pkgs/container/lotus-fvm-localnet-lite

# License

Apache 2 or MIT
