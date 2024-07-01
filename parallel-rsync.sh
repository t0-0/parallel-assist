#!/bin/bash

remote_name=$1
remote_dir=$2
num_thread=$3
local_dir=$4

# 転送するファイルをファイルサイズが大きい順に並べる
file_list=$(ssh $1 "find $2 -type f | xargs ls -S --quoting-style=shell-always")

mpirun -n $num_thread -x file_list="${file_list}" -x remote_name=${remote_name} -x remote_dir=${remote_dir} -x local_dir=${local_dir} bash rsync_inner.sh
