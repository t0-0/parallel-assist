#!/bin/bash

file_list=($file_list)

for ((i=${OMPI_COMM_WORLD_RANK}; i<${#file_list[@]}; i+=$((2*${OMPI_COMM_WORLD_SIZE})))) do
    file_name=${file_list[i]}
    file_name=${file_name#\'}
    file_name=${file_name%\'}
    file_name=${file_name/${remote_dir}/''}
    echo $file_name >>${tmp_dir}/${OMPI_COMM_WORLD_RANK}.txt
done

for ((i=$((2*${OMPI_COMM_WORLD_SIZE}-${OMPI_COMM_WORLD_RANK}-1)); i<${#file_list[@]}; i+=$((2*${OMPI_COMM_WORLD_SIZE})))) do
    file_name=${file_list[i]}
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
