# This Dockerfile is used to build an headles vnc image based on Centos

FROM scientificlinux/sl:7

ENV REFRESHED_AT 2021-04-13

ENV UPS_OVERRIDE="-H Linux64bit+3.10-2.17"

# Tools for building the DAQ release

RUN yum clean all \
 && yum -y install epel-release \
 && yum -y install https://repo.ius.io/ius-release-el7.rpm \
 && yum -y update \
 && yum -y install libzstd git224 \
    make redhat-lsb-core glibc-devel \
    openssl-devel xz-devel bzip2-devel libcurl-devel \
    openssl libzstd-devel cyrus-sasl-devel xxhash \
 && yum clean all

# Common system tools requried to run various bash scripts
RUN yum clean all \
 && yum -y install \
    wget curl tar zip rsync openssh-server \
 && yum clean all


ENTRYPOINT ["/bin/bash"]
