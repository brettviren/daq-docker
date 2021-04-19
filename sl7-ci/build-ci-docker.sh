#!/bin/bash
set -e

nightly_tag="N$(date +%y-%m-%d)"
docker_tag="dunedaq/sl7-minimal:dev"
docker_nightly_tag="dunedaq/sl7-minimal-nightly:N$(date +%y-%m-%d)"

docker pull dunedaq/sl7-minimal:latest

docker run --rm -it -v /home/dingpf/cvmfs_dunedaq:/cvmfs/dunedaq.opensciencegrid.org  -v /home/dingpf/cvmfs_dunedaq-dev:/cvmfs/dunedaq-development.opensciencegrid.org -v $PWD:/scratch dunedaq/sl7-minimal:latest /scratch/build-release.sh
docker run --rm -it -v /home/dingpf/cvmfs_dunedaq:/cvmfs/dunedaq.opensciencegrid.org  -v /home/dingpf/cvmfs_dunedaq-dev:/cvmfs/dunedaq-development.opensciencegrid.org -v $PWD:/scratch dunedaq/sl7-minimal:latest /scratch/create-image.sh

docker build --file Dockerfile --tag $docker_tag $PWD

docker push $docker_tag
docker tag $docker_tag $docker_nightly_tag
docker push $docker_nightly_tag

touch "/home/dingpf/nightly-docker/CREATE_${nightly_tag}"
/home/dingpf/nightly-docker/create-nightly-tarball.sh


