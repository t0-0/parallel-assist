#!/bin/bash

if [ -z "${file_str}" ]; then
    exit 1
elif [ -z ${tmp_dir} ]; then
    exit 1
elif [ -z ${remote_name} ]; then
    exit 1
elif [ -z ${local_dir} ]; then
    exit 1
fi

read -r -a file_array <<<$file_str

for ((i = ${OMPI_COMM_WORLD_RANK}; i < ${#file_array[@]}; i += $((2 * ${OMPI_COMM_WORLD_SIZE})))); do
    file_name=${file_array[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    file_name=${file_name/${remote_dir}/''}
    echo $file_name >>${tmp_dir}/${OMPI_COMM_WORLD_RANK}.txt
done

for ((i = $((2 * ${OMPI_COMM_WORLD_SIZE} - ${OMPI_COMM_WORLD_RANK} - 1)); i < ${#file_array[@]}; i += $((2 * ${OMPI_COMM_WORLD_SIZE})))); do
    file_name=${file_array[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    file_name=${file_name/${remote_dir}/''}
    echo $file_name >>${tmp_dir}/${OMPI_COMM_WORLD_RANK}.txt
done

while true; do
    rsync -avz --files-from="${tmp_dir}/${OMPI_COMM_WORLD_RANK}.txt" ${remote_name}:${remote_dir} ${local_dir}
    if [ $? -eq 0 ]; then
        break
    else
        echo "try again"
    fi
done
