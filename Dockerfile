# syntax=docker/dockerfile:1.4

# See: https://github.com/moby/buildkit/blob/master/frontend/dockerfile/docs/syntax.md

FROM ubuntu

RUN useradd ubuntu

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata

RUN apt install -y mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget
RUN apt install -y python3 vim less tmux psmisc htop rsync unzip

#RUN curl -fsSL https://deb.nodesource.com/setup_17.x | bash -
#RUN apt install -y nodejs

# Ubuntu "jammy" is too new and not supported by nodesource yet
# https://github.com/nodesource/distributions#manual-installation
ENV KEYRING=/usr/share/keyrings/nodesource.gpg
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee "$KEYRING" >/dev/null
# wget can also be used:
# wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | tee "$KEYRING" >/dev/null
RUN gpg --no-default-keyring --keyring "$KEYRING" --list-keys
ENV VERSION=node_17.x
# The below command will set this correctly, but if lsb_release isn't available, you can set it manually:
# - For Debian distributions: jessie, sid, etc...
# - For Ubuntu distributions: xenial, bionic, etc...
# - For Debian or Ubuntu derived distributions your best option is to use the codename corresponding to the upstream release your distribution is based off. This is an advanced scenario and unsupported if your distribution is not listed as supported per earlier in this README.
RUN lsb_release -s -c
#ENV DISTRO="$(lsb_release -s -c)"
# Override DISTRO as "jammy" is not supported yet
ENV DISTRO=focal
RUN echo "deb [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRO main" | tee /etc/apt/sources.list.d/nodesource.list
RUN echo "deb-src [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRO main" | tee -a /etc/apt/sources.list.d/nodesource.list
RUN apt-get update
RUN apt install -y nodejs

RUN apt upgrade -y

RUN wget https://go.dev/dl/go1.18.1.linux-amd64.tar.gz
RUN tar -C /usr/local -xf go*.tar.gz
RUN rm -f go*.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"

# https://stackoverflow.com/questions/49676490/when-installing-rust-toolchain-in-docker-bash-source-command-doesnt-work
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y

RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

ENV PATH="/root/.cargo/bin:${PATH}"

WORKDIR /home/ubuntu
COPY . .

RUN chown -R ubuntu. /home/ubuntu
USER ubuntu

WORKDIR /home/ubuntu/lotus

# https://lotus.filecoin.io/developers/local-network/

ENV LOTUS_PATH="~/.lotus-local-net"
ENV LOTUS_MINER_PATH="~/.lotus-miner-local-net"
ENV LOTUS_SKIP_GENESIS_CHECK=_yes_
ENV CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__"
ENV CGO_CFLAGS="-D__BLST_PORTABLE__"

ENV PATH="/home/ubuntu/lotus:${PATH}"

# Build Lotus

RUN make clean 2k

# Setup node

RUN ./lotus fetch-params 2048
RUN ./lotus-seed pre-seal --sector-size 2KiB --num-sectors 2
RUN ./lotus-seed genesis new localnet.json
RUN ./lotus-seed genesis add-miner localnet.json ~/.genesis-sectors/pre-seal-t01000.json

RUN <<'eot' bash
	# Start node

	./lotus daemon --lotus-make-genesis=devgen.car --genesis-template=localnet.json --bootstrap=false | xargs printf -n 1 '[node]%s\n' &
	NODE_PID=$!
	echo Node PID: $NODE_PID

	# Setup miner

	./lotus wallet import --as-default ~/.genesis-sectors/pre-seal-t01000.key
	for i in `seq 1 15`; do
		echo $i
		sleep 1
	done
	echo Done setup miner.
	kill $NODE_PID
eot

