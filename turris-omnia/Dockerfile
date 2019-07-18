# This follows the multi-stage builds pattern described here:
# https://docs.docker.com/develop/develop-images/multistage-build/
#
# By doing this, the final toolchain image is about 5 Gb smaller than the
# toolchain-builder image.
FROM ubuntu:18.04 AS builder-base
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      build-essential libncurses5-dev python unzip \
      git gawk wget file curl sudo runit pkg-config \
      zlib1g-dev libssl-dev subversion unzip libncurses-dev \
      wget python file rsync \
      ccache python-mysqldb python3-mysqldb libmysqlclient-dev

# Make /bin/sh symlink to bash instead of dash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

RUN useradd -m build
RUN echo 'build ALL=(ALL)	NOPASSWD: ALL' >>/etc/sudoers
USER build
WORKDIR /home/build
RUN mkdir share

#########################################################################

FROM builder-base as builder-builder
USER build
WORKDIR /home/build

COPY OpenWrt-SDK-mvebu_gcc-4.8-linaro_musl-1.1.15_eabi.Linux-x86_64.tar.bz2 .
RUN mkdir -p sdk && tar xf OpenWrt-SDK-mvebu_gcc-4.8-linaro_musl-1.1.15_eabi.Linux-x86_64.tar.bz2 -C sdk --strip-components=1
COPY fix-feeds.patch .
RUN patch -p0 < fix-feeds.patch
WORKDIR /home/build/sdk
ENV STAGING_DIR="/home/build/sdk/staging_dir"
ENV PATH="${STAGING_DIR}/toolchain-arm_cortex-a9+vfpv3_gcc-4.8-linaro_musl-1.1.15_eabi/bin:${PATH}"
ENV TERM=xterm
RUN (cd scripts/config && make clean && make)
RUN scripts/feeds update -a
RUN scripts/feeds install node-mozilla-iot-gateway

# Currently, I get errors in mbedtls about libidn.so and if I disable that
# then I get errors about md5 missing from python. I'll have to wait a few days
# and try again

#RUN make

ENTRYPOINT bash

#########################################################################

#FROM builder-base as builder
#USER build
##WORKDIR /home/build
#ENV STAGING_DIR=/home/build/openwrt/staging_dir
#ARG TOOLCHAIN_PATH=${STAGING_DIR}/toolchain-arm_cortex-a7+neon-vfpv4_gcc-7.4.0_musl_eabi
#ENV TOOLCHAIN_PATH=${TOOLCHAIN_PATH}
#ENV CC=${TOOLCHAIN_PATH}/bin/arm-openwrt-linux-gcc
#ENV CXX=${TOOLCHAIN_PATH}/bin/arm-openwrt-linux-g++
#ENV CROSS_COMPILE=arm-openwrt-linux-
#ENV SYSROOT=${TOOLCHAIN_PATH}
#COPY --from=toolchain-builder ${TOOLCHAIN_PATH}/ ${TOOLCHAIN_PATH}/
#RUN sudo bash -c "echo 'owrt-user ALL=(ALL)	NOPASSWD: ALL' >>/etc/sudoers"
#RUN sudo mkdir /owrt
#COPY owrt /owrt
#COPY entrypoint.sh /owrt
#RUN sudo chmod +x /owrt/entrypoint.sh
## Create the .owrt file which is used by build-adapter.sh script from the
## the addon-builder. We need to put this into a file since the ENV statements
## above get "lost" when entrypoint.sh runs chpst.
#RUN sh -c 'echo export STAGING_DIR='${STAGING_DIR}' > .owrt'
#RUN sh -c 'echo export TOOLCHAIN_PATH='${TOOLCHAIN_PATH}' >> .owrt'
#RUN sh -c 'echo export CC='${CC}' >> .owrt'
#RUN sh -c 'echo export CXX='${CXX}' >> .owrt'
#RUN sh -c 'echo export CROSS_COMPILE='${CROSS_COMPILE}' >> .owrt'
#RUN sh -c 'echo export SYSROOT='${SYSROOT}' >> .owrt'
#RUN sh -c 'echo export PATH=\"'${TOOLCHAIN_PATH}'/bin:\${PATH}\" >> .owrt'
#WORKDIR /build
#ENTRYPOINT [ "/owrt/entrypoint.sh" ]