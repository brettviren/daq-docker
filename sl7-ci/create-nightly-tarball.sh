#!/bin/bash

nightly_tag="N$(date +%y-%m-%d)"

cd /home/dingpf/nightly-docker
[ -f "/home/dingpf/nightly-docker/CREATE_${nightly_tag}" ] ||  exit 1

cp -pr image/releases/dunedaq-develop $nightly_tag
sed -i 's,.*releases.*externals,"    /cvmfs/dunedaq-development.opensciencegrid.org/nightly/'"$nightly_tag"'/externals,' $nightly_tag/dbt-settings.sh
sed -i 's,.*releases.*packages,"    /cvmfs/dunedaq-development.opensciencegrid.org/nightly/'"$nightly_tag"'/packages,' $nightly_tag/dbt-settings.sh

tar zcf ${nightly_tag}.tar.gz $nightly_tag
rm -rf /home/dingpf/cvmfs_dunedaq-dev/nightly/$nightly_tag
mv $nightly_tag /home/dingpf/cvmfs_dunedaq-dev/nightly
pushd /home/dingpf/cvmfs_dunedaq-dev/nightly
rm last_successful
ln -s $nightly_tag last_successful
