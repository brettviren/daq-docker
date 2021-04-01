#!/bin/bash

daq_release_branch="develop"
release="dunedaq-develop"
cvmfs_dir="/cvmfs/dunedaq.opensciencegrid.org"
output_list="/scratch/cvmfs_flist.txt"

while getopts ":b:r:o:h" opt; do
  case ${opt} in
    b )
       daq_release_branch=$OPTARG
       ;;
    r )
       release=$OPTARG
       ;;
    o )
       output_list=$OPTARG
       ;;
    h )
      echo "Usage:"
      echo "    get_cvmfs_dirs_of_externas.sh  -h Display this help message."
      echo "    [-b] <branch/commit/tag of daq-release repo>"
      echo "    [-r] <release name under daq-release/configs>"
      echo "    [-o] <output list file>"
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
rm -f dbt-settings.sh
wget https://raw.githubusercontent.com/DUNE-DAQ/daq-release/develop/configs/dunedaq-develop/dbt-settings.sh

source dbt-settings.sh

for prod in "${dune_externals[@]}"; do
    prodArr=(${prod})

    setup_cmd="setup -B ${prodArr[0]//-/_} ${prodArr[1]}"
    if [[ ${#prodArr[@]} -eq 3 ]]; then
        setup_cmd="${setup_cmd} -q ${prodArr[2]}"
    fi
    echo $setup_cmd
    ${setup_cmd}
done

rm -rf $output_list

for i in `ups active| sed 1d| awk '{print $1}'| tr [a-z] [A-Z]`
do
    if [ $i = "UPS" ]; then
        continue
    fi
    j=${i}_DIR
    echo ${!j} >> $output_list
    echo ${!j}.version >> $output_list
done

# Now adding additonal dirs

echo "/cvmfs/dunedaq.opensciencegrid.org/products/cetpkgsupport/current.chain">>$output_list
echo "/cvmfs/dunedaq.opensciencegrid.org/products/setup">>$output_list
echo "/cvmfs/dunedaq.opensciencegrid.org/products/setups">>$output_list
echo "/cvmfs/dunedaq.opensciencegrid.org/products/setups.new">>$output_list
echo "/cvmfs/dunedaq.opensciencegrid.org/products/setups_layout">>$output_list
echo "/cvmfs/dunedaq.opensciencegrid.org/products/ups">>$output_list
echo "/cvmfs/dunedaq.opensciencegrid.org/products/.updfiles">>$output_list
echo "/cvmfs/dunedaq.opensciencegrid.org/products/.upsfiles">>$output_list
echo "/cvmfs/dunedaq.opensciencegrid.org/pypi-repo">>$output_list

# Now make cvmfs mirror
/scratch/copy-cvmfs-files.py $output_list /scratch/cvmfs_mirror

rm -f /scratch/dbt-settings.sh
rm -f $output_list
