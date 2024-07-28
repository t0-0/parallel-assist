#!/bin/bash

source_file=$(realpath $1)
dest_dir=$2
num_thread=$3

mkdir -p ${dest_dir}

dest_dir=$(realpath ${dest_dir})

tar_version=$(tar --version 2>&1)
if echo ${tar_version} | grep -q "bsdtar"; then
    tmp_str="$(tar tvf ${source_file} | sort -k5nr | awk '{print $9}')"
elif echo ${tar_version} | grep -q "GNU tar"; then
    tmp_str="$(tar tvf ${source_file} | sort -k3nr | awk '{print $6}')"
else
    echo "unknown tar"
    exit 1
fi

tmp_array=($tmp_str)

file_array=()

for path in "${tmp_array[@]}"; do
    if [[ $path == */ ]]; then
        mkdir -p "${dest_dir}/${path}"
    else
        file_array+=("${path}")
    fi
done

mpirun -n $num_thread -x file_str="${file_array[*]}" -x source_file=${source_file} -x dest_dir=${dest_dir} bash thaw-inner.sh
