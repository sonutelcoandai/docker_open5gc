# BSD 2-Clause License
#
# Copyright (c) 2020-2025, Supreeth Herle
# All rights reserved.
#
# (license text unchanged...)

##############################
# 1) Builder image
##############################
FROM ubuntu:focal AS builder

ENV DEBIAN_FRONTEND=noninteractive

# --- Add MongoDB 4.4 repo for Ubuntu 20.04 (focal) ---
RUN apt-get update && \
    apt-get install -y gnupg curl ca-certificates && \
    curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc \
      | gpg -o /usr/share/keyrings/mongodb-server-4.4.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-4.4.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" \
      > /etc/apt/sources.list.d/mongodb-org-4.4.list && \
    apt-get update

# --- Build dependencies (Open5GS + tools) ---
RUN apt-get install -y --no-install-recommends \
        python3-pip \
        python3-setuptools \
        python3-wheel \
        ninja-build \
        build-essential \
        flex \
        bison \
        git \
        cmake \
        libsctp-dev \
        libgnutls28-dev \
        libgcrypt-dev \
        libssl-dev \
        libidn11-dev \
        libmongoc-dev \
        libbson-dev \
        libyaml-dev \
        meson \
        mongodb-org \
        libmicrohttpd-dev \
        libcurl4-gnutls-dev \
        libnghttp2-dev \
        libtins-dev \
        libtalloc-dev \
        netbase \
        pkg-config

# --- NodeJS (for WebUI) ---
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=20 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs

# --- Get open5gs source and build it ---
RUN git clone --recursive https://github.com/open5gs/open5gs /open5gs && \
    cd /open5gs && \
    git checkout 47d0062c9e93dc4690c2a0bc6ce06d23dba4e997 && \
    meson build --prefix=/open5gs/install && \
    ninja -C build && \
    cd build && ninja install && \
    mkdir -p /open5gs/install/include

# --- Build WebUI ---
RUN cd /open5gs/webui && npm ci

##############################
# 2) Final runtime image
##############################
FROM ubuntu:focal

ENV DEBIAN_FRONTEND=noninteractive

# --- Add MongoDB 4.4 repo (same as builder) ---
RUN apt-get update && \
    apt-get install -y gnupg curl ca-certificates && \
    curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc \
      | gpg -o /usr/share/keyrings/mongodb-server-4.4.gpg --dearmor && \
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-4.4.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" \
      > /etc/apt/sources.list.d/mongodb-org-4.4.list && \
    apt-get update

# --- Runtime dependencies + tools inside container ---
RUN apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        libssl-dev \
        libyaml-dev \
        libmicrohttpd-dev \
        libmongoc-dev \
        libsctp-dev \
        libcurl4-gnutls-dev \
        libtins-dev \
        libidn11-dev \
        libtalloc-dev \
        netbase \
        ifupdown \
        net-tools \
        iputils-ping \
        python3-setuptools \
        python3-wheel \
        python3-pip \
        iptables \
        iperf \
        iperf3 \
        traceroute \
        tcpdump \
        mongodb-org \
        gnupg && \
    apt-get autoremove -y && \
    apt-get autoclean

RUN pip3 install click

# --- NodeJS for WebUI in runtime too ---
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    NODE_MAJOR=20 && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    update-ca-certificates

# --- Copy Open5GS build artifacts from builder image ---
COPY --from=builder /open5gs/install/bin /open5gs/install/bin
COPY --from=builder /open5gs/install/etc /open5gs/install/etc
COPY --from=builder /open5gs/install/include /open5gs/install/include
COPY --from=builder /open5gs/install/lib /open5gs/install/lib
COPY --from=builder /open5gs/webui /open5gs/webui
COPY --from=builder /open5gs/misc/db /open5gs/misc/db

# --- Working directory and entrypoint ---
WORKDIR /open5gs

COPY open5gs_init.sh /
CMD ["/open5gs_init.sh"]
