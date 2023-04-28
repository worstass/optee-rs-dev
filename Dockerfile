FROM ubuntu:focal
ENV DEBIAN_FRONTEND noninteractive
ENV OPTEE_VERSION 3.20.0
RUN apt-get update && \
    apt-get install -y \
      curl \
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
      cmake gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf binutils-aarch64-linux-gnu \
      binutils-aarch64-linux-gnu binutils-arm-linux-gnueabihf \
      pkg-config-aarch64-linux-gnu pkg-config-arm-linux-gnueabihf && \
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
    cd optee_client && mkdir build && cd build && \
    cmake -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_INSTALL_PREFIX=/optee/optee_client .. && \
    make install && \
    mkdir -p /optee/optee_client/libteec && cd /optee/optee_client/libteec && ln -s ../lib/libteec.a libteec.a && \
    cd /build && rm -rf optee_client/

ENV OPTEE_DIR /optee
WORKDIR /optee
RUN git clone https://github.com/apache/incubator-teaclave-trustzone-sdk.git optee_rust && \
    cd optee_rust && \
    git checkout ae006b2 && \
    sed -i 's/1.56.0/1.57.0/g' setup.sh && \
    mkdir -p $HOME/.cargo && touch $HOME/.cargo/env && \
    ./setup.sh
