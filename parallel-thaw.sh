#!/bin/bash

source_file=$(realpath $1)
dest_dir=$2
num_thread=$3

mkdir -p ${dest_dir}

dest_dir=$(realpath ${dest_dir})

tmp_list=($(tar tvf ${source_file} | sort -k5nr | awk '{print $9}'))

file_list=()

for path in "${tmp_list[@]}"; do
    if [[ $path == */ ]]; then
        mkdir -p "${dest_dir}/${path}"
    else
        file_list+=(${path})
    fi
done

mpirun -n $num_thread -x file_list="${file_list[*]}" -x source_file=${source_file} -x dest_dir=${dest_dir} bash thaw-inner.sh
