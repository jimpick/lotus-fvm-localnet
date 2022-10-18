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

The image is built using GitHub Actions. 

* https://github.com/jimpick/lotus-fvm-localnet/actions/workflows/container-ready.yml

The image is uploaded to the GitHub Container registry and can be referred to as:

* `ghcr.io/jimpick/lotus-fvm-localnet-ready:latest`

Or, even better, get the latest digest hash from the action to refer to an immutable
version, eg.:

* `ghcr.io/jimpick/lotus-fvm-localnet-ready@sha256:f181f34189fd9b4ec7e3690ceca2c7d3d620a3fa9c9a06fb766049742d58b161`

The image is built in two stages. There is another image `jimpick/lotus-fvm-localnet-base`
that just contains the built version of Lotus and the downloaded params, but hasn't
been bootstrapped with genesis/sectors yet.

# Usage: Docker

Run the node:

```
docker run -i -t --rm --name lotus-fvm-localnet ghcr.io/jimpick/lotus-fvm-localnet-ready:latest lotus daemon --lotus-make-genesis=devgen.car --genesis-template=localnet.json --bootstrap=false
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
    image: ghcr.io/jimpick/lotus-fvm-localnet-ready@sha256:f181f34189fd9b4ec7e3690ceca2c7d3d620a3fa9c9a06fb766049742d58b161
    command: [ bash, -c ]
    args:
      - |
        lotus daemon --lotus-make-genesis=devgen.car --genesis-template=localnet.json --bootstrap=false
    tty: true
  - name: miner
    image: ghcr.io/jimpick/lotus-fvm-localnet-ready@sha256:f181f34189fd9b4ec7e3690ceca2c7d3d620a3fa9c9a06fb766049742d58b161
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


# License

Apache 2 or MIT
