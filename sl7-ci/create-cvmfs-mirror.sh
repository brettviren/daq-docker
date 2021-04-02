#!/bin/bash

function setup_prds {
    prd_list_name=$1[@]
    prd_list=("${!prd_list_name}")
    for prod in "${prd_list[@]}"; do
        prodArr=(${prod})
        setup_cmd="setup -B ${prodArr[0]//-/_} ${prodArr[1]}"
        if [[ ${#prodArr[@]} -eq 3 ]]; then
            setup_cmd="${setup_cmd} -q ${prodArr[2]}"
        fi
        echo $setup_cmd
        ${setup_cmd}
    done
}


daq_release_branch="develop"
release="dunedaq-develop"
outdir="/scratch/image"

cvmfs_dir="/cvmfs/dunedaq.opensciencegrid.org"
outdir_cvmfs="$outdir/cvmfs_mirror/dunedaq.opensciencegrid.org"
outdir_release="$outdir/releases/$release"

while getopts ":b:r:o:h" opt; do
  case ${opt} in
    b )
       daq_release_branch=$OPTARG
       ;;
    r )
       release=$OPTARG
       ;;
    o )
       outdir=$OPTARG
       ;;
    h )
      echo "Usage:"
      echo "    get_cvmfs_dirs_of_externas.sh  -h Display this help message."
      echo "    [-b] <branch/commit/tag of daq-release repo>"
      echo "    [-r] <release name under daq-release/configs>"
      echo "    [-o] <output dir path for cvmfs mirror and releases>"
      exit 0
      ;;
   \? )
     echo "Invalid Option: -$OPTARG" 1>&2
     exit 1
     ;;
  esac
done

source $cvmfs_dir/products/setup

cd /scratch
git clone https://github.com/DUNE-DAQ/daq-release.git -b $daq_release_branch
cd /scratch/daq-release && git pull
cd /scratch

source /scratch/daq-release/configs/$release/dbt-settings.sh
export PATH=/scratch/daq-release/scripts:$PATH

create-ups-products-area.sh -t $outdir_cvmfs/products
create-ups-products-area.sh -t $outdir_release/packages
create-ups-products-area.sh -t $outdir_release/externals
setup_prds dune_externals
setup_prds dune_systems
setup_prds dune_devtools

for prod in "${dune_externals[@]}"; do
    prodArr=(${prod})

    setup_cmd="setup -B ${prodArr[0]//-/_} ${prodArr[1]}"
    if [[ ${#prodArr[@]} -eq 3 ]]; then
        setup_cmd="${setup_cmd} -q ${prodArr[2]}"
    fi
    echo $setup_cmd
    ${setup_cmd}
done

for prd in `ups active| sed 1d| awk '{print $1}'`
do
    exclude_list="clang ups"
    #exclude_list="gcc boost clang hdf5 ups"
    if [[ $exclude_list =~ (^|[[:space:]])"$prd"($|[[:space:]]) ]]; then
        continue
    fi
    i=`echo $prd|tr [a-z] [A-Z]`
    j=${i}_DIR
    prd_path=`dirname ${!j}`
    prd_ver=`basename ${!j}`
    srcs=($cvmfs_dir/products/$prd/$prd_ver
	    $cvmfs_dir/products/$prd/${prd_ver}.version
	    $cvmfs_dir/products/$prd/current.chain
    )
    link_dests=($outdir_release/externals/$prd/$prd_ver
	    $outdir_release/externals/$prd/${prd_ver}.version
	    $outdir_release/externals/$prd/current.chain
    )
    cvmfs_dests=($outdir_cvmfs/products/$prd/$prd_ver
	    $outdir_cvmfs/products/$prd/${prd_ver}.version
	    $outdir_cvmfs/products/$prd/current.chain
    )
    if [ -d ${srcs[0]} ]; then
	if [ -d ${cvmfs_dests[0]} ]; then
		echo "Info: ${cvmfs_dests[0]} exists, skip."
	else
		[[ -d `dirname ${cvmfs_dests[0]}` ]] && rm -rf dirname ${cvmfs_dests[0]}/*
		[[ -d `dirname ${link_dests[0]}` ]] && rm -rf `dirname ${link_dests[0]}`/*
		mkdir -p `dirname ${link_dests[0]}`
		for k in `seq 0 2`; do
                    if [ -d ${srcs[k]} ]; then
                        rsync -ah ${srcs[k]} `dirname  ${cvmfs_dests[0]}`
			echo "found ${srcs[k]}"
                        ln -s ${srcs[k]} ${link_dests[k]}
		    fi
                done
	fi
    fi
done

rsync -ah /cvmfs/dunedaq.opensciencegrid.org/pypi-repo $outdir_cvmfs
rsync -ah /scratch/daq-release/configs/$release/dbt-settings.sh $outdir_release
rsync -ah /scratch/daq-release/configs/$release/dbt-build-order.cmake $outdir_release
rsync -ah /scratch/daq-release/configs/$release/pyvenv_requirements.txt $outdir_release

