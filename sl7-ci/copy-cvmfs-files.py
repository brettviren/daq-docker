#!/usr/bin/env python

import os
import sys
import shutil
import errno
#for i in `ups active | awk '{print $1}'| tr [a-z] [A-Z]`; do j=${i}_DIR; echo ${!j}; done| tee dirs.txt

ignore = shutil.ignore_patterns('source', '*debug', 'src')

def copyfile(src, dst):
    dir_name = os.path.dirname(dst)
    print("checking dir: ", dir_name)
    if not os.path.exists(dir_name):
        print ("making dir: ", dir_name)
        os.makedirs(dir_name)
    shutil.copy(src, dst)
    return

def copyanything(src, dst):
    if os.path.exists(dst):
        print("### WARNING! destination folder exists, skipping!\n")
        return
    try:
        shutil.copytree(src, dst, symlinks=True)
    except OSError as exc: # python >2.5
        if exc.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else: raise
    return

# get list of dirs from input file

if len(sys.argv) != 3:
    print("usage: copy_cvmfs_files.py list.txt dest_dir")

input_list = sys.argv[1]

dest_root_dir = sys.argv[2]

with open(input_list, 'r') as inlist:
    for iline in inlist:
        isrc = iline.strip()
        if not isrc:
            continue
        idest = os.path.join(dest_root_dir, os.path.relpath(isrc, '/cvmfs'))
        print("{} --> {}".format(isrc, idest))
        if os.path.isdir(isrc):
            copyanything(isrc, idest)
        if os.path.isfile(isrc):
            copyfile(isrc, idest)
