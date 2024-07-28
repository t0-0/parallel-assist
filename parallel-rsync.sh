#!/bin/bash

remote_name=$1
remote_dir=$2
num_thread=$3
local_dir=$4
tmp_dir=$5

# 転送するファイルをファイルサイズが大きい順に並べる
file_list=$(ssh $1 "find $2 -type f | xargs ls -S --quoting-style=shell-always")
if [ $? -ne 0 ]; then
    echo "must check remote_name or remote_dir"
    exit 1
fi

[ -d ${tmp_dir} ] && echo "${tmp_dir} must not exist" && exit 1
mkdir -p ${tmp_dir}
mkdir -p ${local_dir}

mpirun -n $num_thread -x file_str="${file_list}" -x remote_name=${remote_name} -x remote_dir=${remote_dir} -x local_dir=${local_dir} -x tmp_dir=${tmp_dir} bash rsync_inner.sh

rm -rf ${tmp_dir}
