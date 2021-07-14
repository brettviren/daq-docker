# This Dockerfile is used to build an headles vnc image based on Centos

FROM scientificlinux/sl:7

MAINTAINER Pengfei Ding "dingpf@fnal.gov"
ENV REFRESHED_AT 2020-10-19

RUN yum clean all \
 && yum -y install epel-release \
 && yum -y install https://repo.ius.io/ius-release-el7.rpm
 && yum -y update \
 && yum -y install yum-plugin-priorities \
 git224 subversion asciidoc bzip2-devel \
 fontconfig-devel freetype-devel gdbm-devel glibc-devel \
 ncurses-devel openssl-devel openldap-devel readline-devel \
 autoconf automake libtool swig texinfo tcl-devel tk-devel \
 xz-devel xmlto zlib-devel libcurl-devel libjpeg-turbo-devel \
 libpng-devel libstdc++-devel libuuid-devel libX11-devel \
 libXext-devel libXft-devel libXi-devel libXrender-devel \
 libXt-devel libXpm-devel libXmu-devel mesa-libGL-devel \
 mesa-libGLU-devel perl-DBD-SQLite perl-ExtUtils-MakeMaker \
 gcc gcc-c++ libgcc.i686 glibc-devel.i686 libstdc++.i686 libffi-devel \
 && yum -y install yum-plugin-priorities \
 nc perl expat-devel gdb time tar zip xz bzip2 patch sudo which strace \
 openssh-clients rsync tmux svn wget cmake \
 gcc gstreamer gtk2-devel xterm \
 gstreamer-plugins-base-devel  \
 vim which net-tools xorg-x11-fonts* \
 xorg-x11-server-utils xorg-x11-twm dbus dbus-x11 \
 libuuid-devel wget redhat-lsb-core openssh-server \
 && yum clean all

RUN yum clean all \
 && yum --enablerepo=epel -y install htop osg-wn-client \
 libconfuse-devel xvfb nss_wrapper gettext libzstd libzstd-devel openssl \
 && yum clean all

RUN yum clean all \
 && yum -y install java-11-openjdk \
 && yum clean all


ENV UPS_OVERRIDE="-H Linux64bit+3.10-2.17"

RUN dbus-uuidgen > /var/lib/dbus/machine-id

RUN yum clean all \
 && yum -y install glew-devel unzip perl-ExtUtils-Embed expect \
 && yum clean all

RUN yum clean all \
 && yum -y install xxhash cyrus-sasl-devel \
 && yum clean all

ENTRYPOINT ["/bin/bash"]
