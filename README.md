lotus-fvm-localnet
===

[![lotus-fvm-localnet-lite](https://github.com/jimpick/lotus-fvm-localnet/actions/workflows/container-lite.yml/badge.svg)](https://github.com/jimpick/lotus-fvm-localnet/actions/workflows/container-lite.yml)

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
docker run -p 1234:1234 -i -t --rm --name lotus-fvm-localnet ghcr.io/jimpick/lotus-fvm-localnet-lite:latest lotus daemon --lotus-make-genesis=devgen.car --genesis-template=localnet.json --bootstrap=false
```

In another terminal, run the miner:

```
docker exec -i -t lotus-fvm-localnet lotus-miner run --nosync
```

Watch the chain progress:

```
docker exec -it lotus-fvm-localnet watch lotus chain list --count=3
```

Access the JSON-RPC API on the node using CURL:

```
$ curl -s -X POST -H "Content-Type: application/json" --data '{ "jsonrpc": "2.0", "method": "Filecoin.ChainHead", "params": [], "id": 1 }' http://127.0.0.1:1234/rpc/v0 | jq
{
  "jsonrpc": "2.0",
  "result": {
    "Cids": [
      {
        "/": "bafy2bzacecjp2ovazcmaujizsmnrekde5rqeadjaykpzetvzsw7mf2s33xmi6"
      }
    ],
    "Blocks": [
      {
        "Miner": "t01000",
        "Ticket": {
          "VRFProof": "p2w665bgCcyXBAlB3KAQZV/BxEVBASYliPvCefmzRGIuYNMT65Z+pVmblhTUhP3QBZwne9sJAUZ7g955ATwHo8cpC3rgmej0vz9iCfqv+vpIinZklywRh3nBJ40xz9Rl"
        },
        "ElectionProof": {
          "WinCount": 7,
          "VRFProof": "lcaJloFrr6l+fKnZb3UW1EELJDHALTNHG9HE8eDAtJ0NBSimQh4xURmCx4iWLQkMDrTB2O+l++dcxgASxlM9lZnD+f1CkzcJ5KEWgPZYRwh3dmoRs9DAwsZXV1/T5tOh"
        },
        "BeaconEntries": null,
        "WinPoStProof": [
          {
            "PoStProof": 0,
            "ProofBytes": "uHFisqy0U48VZb9NoHnHIGdxSpkIibbVjerfBivPZdPBU2WQ6gh9NSKvqUW2W9aGkvOGkH5HPFZZ9jh8ZXJtf6Ubbmj+WGK16VShSXuCUGd6ysLgoKni+z1dcj5Q9X7ZCbh7SqON2yT8sMw8c3uqhka50zdb7fZZ+eaMb3SKHJpKSiLL2+Mzwc1L44P4yjdlpErxnTePte86rt97+ShWUtcyySph0heGbQk4gt/QMcAyAHF1qEhLcacLrxDEYg80"
          }
        ],
        "Parents": [
          {
            "/": "bafy2bzacea66mb76bz2m45yklsxrzggs7bbwafvnkshc6rr4dy3vuobvgxafs"
          }
        ],
        "ParentWeight": "626304",
        "Height": 109,
        "ParentStateRoot": {
          "/": "bafy2bzacebx7ho2vt6wutvwi4oejor3u6l4b5w5xfic6cm7tgxwu5j44xp4aw"
        },
        "ParentMessageReceipts": {
          "/": "bafy2bzacedswlcz5ddgqnyo3sak3jmhmkxashisnlpq6ujgyhe4mlobzpnhs6"
        },
        "Messages": {
          "/": "bafy2bzacecmda75ovposbdateg7eyhwij65zklgyijgcjwynlklmqazpwlhba"
        },
        "BLSAggregate": {
          "Type": 2,
          "Data": "wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
        },
        "Timestamp": 1666121874,
        "BlockSig": {
          "Type": 2,
          "Data": "tXc3jZEXTau5MU4XtF39bpadEocCxqM4coSuPuAilf0MfH45jwRGF7uochua9QgxCdzfWjVqBlb4Oi7QeBQZFO6YNrVDG1AyNa2oP7jU8vvFTkEHFgq1gnc28ReSttXz"
        },
        "ForkSignaling": 0,
        "ParentBaseFee": "100"
      }
    ],
    "Height": 109
  },
  "id": 1
}
```

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


# Building Images

Because the Docker image takes a very long time to build, it is built in
a number of stages using GitHub Actions.

## ubuntu-dev

This image has a full Ubuntu development setup with Go and Rust.

* Action: https://github.com/jimpick/lotus-fvm-localnet/actions/workflows/container-ubuntu-dev.yml
* Dockerfile: https://github.com/jimpick/lotus-fvm-localnet/blob/main/Dockerfile-ubuntu-dev
* Package: https://github.com/jimpick/lotus-fvm-localnet/pkgs/container/lotus-fvm-localnet-ubuntu-dev

## base

This adds a built version of Lotus along with the source code. Heavy!

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

## python

This image is the "lite" image plus python3.

* Action: https://github.com/jimpick/lotus-fvm-localnet/actions/workflows/container-python.yml
* Dockerfile: https://github.com/jimpick/lotus-fvm-localnet/blob/main/Dockerfile-python
* Package: https://github.com/jimpick/lotus-fvm-localnet/pkgs/container/lotus-fvm-localnet-python

# License

Apache 2 or MIT
