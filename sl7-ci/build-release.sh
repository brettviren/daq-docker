#!/bin/bash

daq_release_branch="develop"
daq_buildtools_branch="develop"
release="dunedaq-develop"
package_checkout_branch="develop" # dunedaq-v2.4.0 or develop
workdir=/scratch


cd $workdir
git clone https://github.com/DUNE-DAQ/daq-release.git -b $daq_release_branch
cd $workdir/daq-release && git pull
cd $workdir

git clone https://github.com/DUNE-DAQ/daq-buildtools.git -b $daq_buildtools_branch

export DBT_ROOT=$workdir/daq-buildtools
source ${DBT_ROOT}/scripts/dbt-setup-tools.sh
add_many_paths PATH ${DBT_ROOT}/bin ${DBT_ROOT}/scripts
source $workdir/daq-release/configs/$release/dbt-settings.sh
export PATH=$workdir/daq-release/scripts:$PATH

setup_ups_product_areas
setup_ups_products dune_devtools
setup_ups_products dune_systems
setup_ups_products dune_externals

echo "============================"
echo "dbt-create dev now"
echo "============================"
dbt-create.sh -r $workdir/daq-release/configs dunedaq-develop dev

cd dev
cp $workdir/daq-release/configs/$release/release_manifest.sh .
$workdir/daq-release/scripts/checkout-package.sh -f ./release_manifest.sh -a -b $package_checkout_branch -o sourcecode

export DBT_AREA_ROOT="$workdir/dev"
export DBT_AREA_FILE="dbt-settings"
source ${DBT_AREA_ROOT}/${DBT_AREA_FILE}
source ${DBT_AREA_ROOT}/${DBT_VENV}/bin/activate 
export DBT_SETUP_BUILD_ENVIRONMENT_SCRIPT_SOURCED=1
export DBT_INSTALL_DIR=${DBT_AREA_ROOT}/install

dbt-build.sh --install
