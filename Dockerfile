FROM ubuntu:focal
ENV DEBIAN_FRONTEND noninteractive
ENV OPTEE_VERSION 3.20.0
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      git \
      autoconf \
      automake \
      build-essential \
      libssl-dev \
      libtool \
      make \
      ninja-build \
      cmake gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN git clone --depth 1 -b ${OPTEE_VERSION} https://github.com/OP-TEE/optee_os && \
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
      PLATFORM=vexpress-qemu_armv8a
RUN git clone https://github.com/OP-TEE/optee_client && \
    cd optee_client && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_C_COMPILER=aarch64-linux-gnu-gcc -DCMAKE_INSTALL_PREFIX=/optee/optee_client .. && \
    make
