# This Dockerfile is used to build an headles vnc image based on Centos

FROM scientificlinux/sl:7

ENV REFRESHED_AT 2021-01-28

ENV UPS_OVERRIDE="-H Linux64bit+3.10-2.17"

# Tools for building the DAQ release

RUN yum clean all \
 && yum -y install \
    make redhat-lsb-core glibc-devel \
    openssl-devel xz-devel bzip2-devel \
 && yum clean all

# Common system tools requried to run various bash scripts
RUN yum clean all \
 && yum -y install \
    git wget curl tar zip \
 && yum clean all

ENTRYPOINT ["/bin/bash"]
