FROM ubuntu:focal
ENV DEBIAN_FRONTEND noninteractive
ENV OPTEE_VERSION 3.20.0
RUN apt-get update && \
    apt-get install -y \
      ca-certificates \
      git \
      autoconf \
      automake \
      build-essential \
      libssl-dev \
      libtool \
      make \
      device-tree-compiler \
      ninja-build \
      python3-crypto \
      python3-cryptography \
      python3-pip \
      python3-pyelftools \
      python3-serial \
      uuid-dev \
      dpkg-dev \
      cmake gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf pkg-config-aarch64-linux-gnu pkg-config-arm-linux-gnueabihf && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /build
RUN git clone --depth 1 -b ${OPTEE_VERSION} https://github.com/OP-TEE/optee_os.git && \
    cd optee_os && \
    make \
      CFG_ARM64_core=y \
      CFG_TEE_BENCHMARK=n \
      CFG_TEE_CORE_LOG_LEVEL=3 \
      CROSS_COMPILE=aarch64-linux-gnu- \
      CROSS_COMPILE_core=aarch64-linux-gnu- \
      CROSS_COMPILE_ta_arm32=arm-linux-gnueabihf- \
      CROSS_COMPILE_ta_arm64=aarch64-linux-gnu- \
      DEBUG=1 \
      O=out/arm \
      PLATFORM=vexpress-qemu_armv8a && \
    mkdir -p /optee/optee_os/arm && \
    cp -r out/arm/export-ta_arm32 /optee/optee_os/arm && \
    cp -r out/arm/export-ta_arm64 /optee/optee_os/arm && \
    cd /build && rm -rf optee_os/
    
RUN git clone --depth 1 -b ${OPTEE_VERSION} https://github.com/OP-TEE/optee_client.git && \
    cd optee_client && \
    make CROSS_COMPILE=aarch64-linux-gnu- DESTDIR=/optee/optee_client
