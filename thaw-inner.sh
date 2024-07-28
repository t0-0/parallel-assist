#!/bin/bash

if [ -z ${dest_dir} ]; then
    exit 1
elif [ -z ${source_file} ]; then
    exit 1
elif [ -z "${file_str}" ]; then
    exit 1
fi

cd "${dest_dir}" || exit 1

file_array=($file_str)

files_to_handle=()

for ((i = ${OMPI_COMM_WORLD_RANK}; i < ${#file_array[@]}; i += $((2 * ${OMPI_COMM_WORLD_SIZE})))); do
    file_name=${file_array[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    files_to_handle+=("${file_name}")
done

for ((i = $((2 * ${OMPI_COMM_WORLD_SIZE} - ${OMPI_COMM_WORLD_RANK} - 1)); i < ${#file_array[@]}; i += $((2 * ${OMPI_COMM_WORLD_SIZE})))); do
    file_name=${file_array[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    files_to_handle+=("${file_name}")
done

while [ ${#files_to_handle[@]} -ne 0 ]; do
    tar xvf ${source_file} "${files_to_handle[@]}"
    if [ $? -eq 0 ]; then
        break
    else
        echo "try again"
    fi
done
