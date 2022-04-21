FROM ubuntu

RUN useradd ubuntu

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata

RUN apt install -y mesa-opencl-icd ocl-icd-opencl-dev gcc git bzr jq pkg-config curl clang build-essential hwloc libhwloc-dev wget
RUN apt install -y python3 vim less tmux psmisc htop rsync unzip

RUN curl -fsSL https://deb.nodesource.com/setup_17.x | bash -
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

RUN mkdir /home/ubuntu
WORKDIR /home/ubuntu
COPY . .
WORKDIR /home/ubuntu/lotus

RUN chown -R ubuntu. /home/ubuntu
USER ubuntu

# https://lotus.filecoin.io/developers/local-network/

ENV LOTUS_PATH="~/.lotus-local-net"
ENV LOTUS_MINER_PATH="~/.lotus-miner-local-net"
ENV LOTUS_SKIP_GENESIS_CHECK=_yes_
ENV CGO_CFLAGS_ALLOW="-D__BLST_PORTABLE__"
ENV CGO_CFLAGS="-D__BLST_PORTABLE__"

RUN make clean 2k
RUN ./lotus fetch-params 2048
RUN ./lotus-seed pre-seal --sector-size 2KiB --num-sectors 2
RUN ./lotus-seed genesis new localnet.json
