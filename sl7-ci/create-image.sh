#!/bin/bash

daq_release_branch="develop"
daq_buildtools_branch="develop"
release="dunedaq-develop"
package_checkout_branch="develop" # dunedaq-v2.4.0 or develop
workdir=/scratch
outdir="$workdir/image"
outdir_release="$outdir/releases/$release"
outdir_cvmfs="$workdir/image/cvmfs/dunedaq.opensciencegrid.org"
outdir_cvmfsdev="$workdir/image/cvmfs/dunedaq-development.opensciencegrid.org"

rm -rf $outdir

export DBT_ROOT=$workdir/daq-buildtools
source ${DBT_ROOT}/scripts/dbt-setup-tools.sh
add_many_paths PATH ${DBT_ROOT}/bin ${DBT_ROOT}/scripts
source $workdir/daq-release/configs/$release/dbt-settings.sh
export PATH=$workdir/daq-release/scripts:$PATH

setup_ups_product_areas
setup_ups_products dune_devtools
setup_ups_products dune_systems
setup_ups_products dune_externals

create-ups-products-area.sh -t $outdir_release/packages
create-ups-products-area.sh -t $outdir_release/externals

cp $workdir/daq-release/configs/$release/dbt-settings.sh $outdir_release
cp $workdir/daq-release/configs/$release/dbt-build-order.cmake $outdir_release
cp $workdir/daq-release/configs/$release/pyvenv_requirements.txt $outdir_release

upsify-daq-pkgs.py -w $workdir/dev -i -o $outdir_release/packages
echo " dune_daqpackages=(" >> $outdir_release/dbt-settings.sh
pushd $outdir_release/packages
find . -type d -name "*.version"|grep -v ups|sed 's/\.\//"/g'|sed 's/\.version/ e19:prof\"/g'|tr '/' ' '|sed -e 's/^/    /'>> $outdir_release/dbt-settings.sh
echo ")">> $outdir_release/dbt-settings.sh

sed -i 's,.*dunedaq.open.*,    "/releases/'"$release"'/packages",' $outdir_release/dbt-settings.sh
sed -i 's,.*dunedaq-development.open.*,    "/releases/'"$release"'/externals",' $outdir_release/dbt-settings.sh

popd

create-ups-products-area.sh -t $outdir_cvmfs/products
create-ups-products-area.sh -t $outdir_cvmfsdev/products

ups active|tail -n +2 | grep -v ups| awk '{ printf "\"%s %s %s\"\n", $1, $2, $NF}'|while read i; do
    i=$(echo $i|tr '"' ' ')
    prd=$(echo $i|cut -d ' ' -f 1)
    prd_ver=$(echo $i|cut -d ' ' -f 2)
    products_dir=$(echo $i|cut -d ' ' -f 3)
    out_cvmfs=$outdir/${products_dir#/}

    exclude_list="clang ups"
    #exclude_list="gcc boost clang hdf5 ups"
    if [[ $exclude_list =~ (^|[[:space:]])"$prd"($|[[:space:]]) ]]; then
	echo "for $prd, outcvmfs is $out_cvmfs"
        continue
    fi
    srcs=($products_dir/$prd/$prd_ver
	    $products_dir/$prd/${prd_ver}.version
	    $products_dir/$prd/current.chain
    )
    link_dests=($outdir_release/externals/$prd/$prd_ver
	    $outdir_release/externals/$prd/${prd_ver}.version
	    $outdir_release/externals/$prd/current.chain
    )
    cvmfs_dests=($out_cvmfs/$prd/$prd_ver
	    $out_cvmfs/$prd/${prd_ver}.version
	    $out_cvmfs/$prd/current.chain
    )
    if [ -d ${srcs[0]} ]; then
	if [ -d ${cvmfs_dests[0]} ]; then
		echo "Info: ${cvmfs_dests[0]} exists, skip."
	else
		[[ -d `dirname ${cvmfs_dests[0]}` ]] && rm -rf `dirname ${cvmfs_dests[0]}`/*
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

rm -rf /scratch/daq-release
rm -rf /scratch/daq-buildtools
rm -rf /scratch/dev

