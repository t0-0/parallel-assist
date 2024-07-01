#!/bin/bash

file_list=($file_list)

for ((i=${OMPI_COMM_WORLD_RANK}; i<${#file_list[@]}; i+=$((2*${OMPI_COMM_WORLD_SIZE})))) do
    file_name=${file_list[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    target_dir=$(dirname ${local_dir}/${file_name/${remote_dir}/''})
    mkdir -p ${target_dir}
    while true; do
        rsync -avz ${remote_name}:${file_name} ${target_dir}
        if [ $? -eq 0 ]; then
            break
        else
            echo "try again"
        fi
    done
done

for ((i=$((2*${OMPI_COMM_WORLD_SIZE}-${OMPI_COMM_WORLD_RANK}-1)); i<${#file_list[@]}; i+=$((2*${OMPI_COMM_WORLD_SIZE})))) do
    file_name=${file_list[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    target_dir=$(dirname ${local_dir}/${file_name/${remote_dir}/''})
    mkdir -p ${target_dir}
    while true; do
        rsync -avz ${remote_name}:${file_name} ${target_dir}
        if [ $? -eq 0 ]; then
            break
        else
            echo "try again"
        fi
    done
done
