# This docker file is to add cvmfs mirror of external dependencies used by the DUNE DAQ development release

FROM dunedaq/sl7-minimal:latest

MAINTAINER Pengfei Ding "dingpf@fnal.gov"
ENV REFRESHED_AT 2021-03-18

ADD cvmfs_mirror /cvmfs

ENTRYPOINT ["/bin/bash"]
