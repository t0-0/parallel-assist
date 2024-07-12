#!/bin/bash

cd ${dest_dir}

file_list=($file_list)

files_to_handle=()

for ((i = ${OMPI_COMM_WORLD_RANK}; i < ${#file_list[@]}; i += $((2 * ${OMPI_COMM_WORLD_SIZE})))); do
    file_name=${file_list[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    files_to_handle+=(${file_name})
done

for ((i = $((2 * ${OMPI_COMM_WORLD_SIZE} - ${OMPI_COMM_WORLD_RANK} - 1)); i < ${#file_list[@]}; i += $((2 * ${OMPI_COMM_WORLD_SIZE})))); do
    file_name=${file_list[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    files_to_handle+=(${file_name})
done

while [ ${#files_to_handle[@]} -ne 0 ]; do
    tar xvf ${source_file} "${files_to_handle[@]}"
    if [ $? -eq 0 ]; then
        break
    else
        echo "try again"
    fi
done
