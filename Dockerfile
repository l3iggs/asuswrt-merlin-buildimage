# this builds the merlin firmwares
FROM ubuntu:12.04
MAINTAINER l3iggs <l3iggs@live.com>

# setup the generic build environment
RUN echo deb http://archive.ubuntu.com/ubuntu/ precise multiverse >> /etc/apt/sources.list
RUN echo deb http://archive.ubuntu.com/ubuntu/ precise-updates multiverse >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get -y dist-upgrade
RUN apt-get install -y git ccache vim
RUN git config --global user.email "buildbot@none.com"
RUN git config --global user.name "Build Bot"

# install dependancies
RUN apt-get install -y autoconf automake bash bison bzip2 diffutils file flex m4 g++ gawk groff-base libncurses-dev libtool libslang2 make patch perl pkg-config shtool tar texinfo zlib1g zlib1g-dev gettext libexpat1-dev libssl-dev cvs gperf unzip python libxml-parser-perl gcc-multilib libxml2-dev g++-4.4 g++-multilib libncurses5 mtd-utils libncurses5-dev libstdc++6-4.4-dev libvorbis-dev g++-4.4-multilib autopoint autogen sed build-essential intltool libelf1:i386 libglib2.0-dev lib32z1-dev lib32stdc++6

# clone source
RUN cd /root && git clone https://github.com/RMerl/asuswrt-merlin.git

# setup path for toolchains
ENV PATH $PATH:/root/asuswrt-merlin/tools/brcm/hndtools-mipsel-uclibc/bin/:/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/bin

# setup ccache
#RUN ln -s /usr/bin/ccache /usr/local/bin/arm-brcm-linux-uclibcgnueabi-gcc
#RUN ln -s /usr/bin/ccache /usr/local/bin/arm-brcm-linux-uclibcgnueabi-g++
#RUN ln -s /usr/bin/ccache /usr/local/bin/arm-brcm-linux-uclibcgnueabi-cc
#RUN ln -s /usr/bin/ccache /usr/local/bin/arm-brcm-linux-uclibcgnueabi-c++

#RUN ln -s /usr/bin/ccache /usr/local/bin/mipsel-linux-uclibc-gcc
#RUN ln -s /usr/bin/ccache /usr/local/bin/mipsel-linux-uclibc-g++
#RUN ln -s /usr/bin/ccache /usr/local/bin/mipsel-linux-uclibc-cc
#RUN ln -s /usr/bin/ccache /usr/local/bin/mipsel-linux-uclibc-c++

# add new tcp algorithm modules
RUN echo "CONFIG_TCP_CONG_ADVANCED=y" >> /root/asuswrt-merlin/release/src-rt-6.x.4708/linux/linux-2.6/config_base.6a
RUN echo "CONFIG_TCP_CONG_VEGAS=m" >> /root/asuswrt-merlin/release/src-rt-6.x.4708/linux/linux-2.6/config_base.6a
RUN echo "CONFIG_TCP_CONG_HTCP=m" >> /root/asuswrt-merlin/release/src-rt-6.x.4708/linux/linux-2.6/config_base.6a
RUN echo "CONFIG_TCP_CONG_HSTCP=m" >> /root/asuswrt-merlin/release/src-rt-6.x.4708/linux/linux-2.6/config_base.6a
RUN echo "CONFIG_TCP_CONG_HYBLA=m" >> /root/asuswrt-merlin/release/src-rt-6.x.4708/linux/linux-2.6/config_base.6a
RUN echo "CONFIG_TCP_CONG_SCALABLE=m" >> /root/asuswrt-merlin/release/src-rt-6.x.4708/linux/linux-2.6/config_base.6a
RUN echo "CONFIG_TCP_CONG_YEAH=m" >> /root/asuswrt-merlin/release/src-rt-6.x.4708/linux/linux-2.6/config_base.6a
RUN echo "CONFIG_TCP_CONG_ILLINOIS=m" >> /root/asuswrt-merlin/release/src-rt-6.x.4708/linux/linux-2.6/config_base.6a

# build firmwares
RUN cd /root/asuswrt-merlin/release/src-rt-6.x.4708/ && make rt-ac87u

# iperf3
RUN cd /root && git clone https://github.com/esnet/iperf.git
RUN cd /root/iperf && CFLAGS=-static LD_LIBRARY_PATH=/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/lib ./bootstrap.sh
RUN cd /root/iperf && CFLAGS=-static LD_LIBRARY_PATH=//root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/lib ./configure --with-sysroot=/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3 --host=arm-brcm-linux-uclibcgnueabi
#this spits out an exe but then fails later
#RUN cd /root/iperf && CFLAGS=-static LD_LIBRARY_PATH=//root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/lib make

# udpxy
RUN cd /root && git clone https://github.com/l3iggs/udpxy.git
RUN cd /root/udpxy/chipmunk && LD_LIBRARY_PATH=/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/lib PATH=$PATH:/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/bin STAGING_DIR=/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3 make CC=arm-brcm-linux-uclibcgnueabi-cc LD=arm-brcm-linux-uclibcgnueabi-ld

# hdhomerun
ADD http://download.silicondust.com/hdhomerun/libhdhomerun_20141024beta2.tgz /root/hdhr/libhdhr.tgz
RUN cd /root/hdhr && tar -xvf libhdhr.tgz
RUN cd /root/hdhr/libhdhome* && LD_LIBRARY_PATH=/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/lib PATH=$PATH:/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3/bin STAGING_DIR=/root/asuswrt-merlin/release/src-rt-6.x.4708/toolchains/hndtools-arm-linux-2.6.36-uclibc-4.5.3 make CC=arm-brcm-linux-uclibcgnueabi-cc LD=arm-brcm-linux-uclibcgnueabi-ld STRIP=LD=arm-brcm-linux-uclibcgnueabi-strip

# display ccache summary
RUN ccache -s
