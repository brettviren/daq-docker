#!/bin/bash

host_cvmfs="/home/dingpf/cvmfs_dunedaq"
docker_tag="dunedaq/sl7-minimal:dev"

docker run --rm -it -v $host_cvmfs:/cvmfs/dunedaq.opensciencegrid.org  -v $PWD:/scratch dunedaq/sl7-minimal /scratch/create-cvmfs-mirror.sh

docker pull dunedaq/sl7-minimal:latest
docker build --file Dockerfile --tag $docker_tag $PWD
docker push $docker_tag



