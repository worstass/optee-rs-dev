FROM ubuntu:focal
ENV OPTEE_VERSION 3.20.0
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      bc \
      bison \
      build-essential \
      ccache \
      cscope \
      curl \
      device-tree-compiler \
      expect \
      flex \
      gdisk \
      iasl \
      libcap-dev \
      libfdt-dev \
      libftdi-dev \
      libglib2.0-dev \
      libgmp3-dev \
      libhidapi-dev \
      libmpc-dev \
      libncurses5-dev \
      libpixman-1-dev \
      libssl-dev \
      libtool \
      make \
      mtools \
      ninja-build \
      rsync \
      unzip \
      uuid-dev \
      xdg-utils \
      xz-utils \
      zlib1g-dev \
      # extra for Docker only \
      git \
      nano \
      cmake gcc-aarch64-linux-gnu gcc-aarch64-linux-gnu gcc-arm-linux-gnueabihf && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /bin/repo
RUN chmod a+x /bin/repo

RUN mkdir repo && \
    cd repo && \
    repo init -u https://github.com/OP-TEE/manifest.git -m qemu_v8.xml -b ${OPTEE_VERSION} && \
    repo sync -j`nproc` && \
    rm -rf .repo && \
    sed -i 's/1.56.0/1.57.0/g' optee_rust/setup.sh && \
    cd build && \
    make toolchains -j`nproc` && \
    make optee-os -j `nproc` && \
    make OPTEE_RUST_ENABLE=y CFG_TEE_RAM_VA_SIZE=0x00300000 -j`nproc` optee-rust
