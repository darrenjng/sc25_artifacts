#!/usr/bin/env bash

# Note: you will need SDR benchmark data: https://sdrbench.github.io/
# Example: ./run_fio_compress.sh -f ~/data/1800x3600 -m '3600 1800' -e 10 2>&1 | tee fio_compress_output.txt

device=/dev/nvme0n1

folder_name=''
dimension=''
compressor='szx'
CR_bound=''
data_type='*.f32'

comp_data_ending='*.szx'
comp_file_sizes=()

while getopts f:m:w:c:de:h flag
do
    case "${flag}" in
        f) folder_name=${OPTARG};;
        m) dimension=${OPTARG};;
        c) compressor=${OPTARG};;
        d) data_type='*.d64'
        data_type_index=1
        double_data='-d'
        ;;
        e) CR_bound=${OPTARG};;
        h) print_help=1;;
    esac
done

file_sizes=()
files=()

for file in $folder_name/$data_type
do 
    do_not_include='log10'
    if [[ "$file" != *"$do_not_include"* ]]; then
        echo "$file"
        fsize=$(wc -c "$file" | awk '{print $1}')
        # flines=$(wc -l "$file" | awk '{print $1}')
        file_sizes+=($fsize)
        # file_num_lines+=($flines)
        files+=($file)
    fi
done

num_files=0
total_raw_bytes=0
for ((i = 0; i < ${#files[@]}; i++))
do
    # echo ${files[i]}
    # echo ${file_sizes[i]}
    total_raw_bytes=$(bc <<< $total_raw_bytes+${file_sizes[i]})
    num_files=$((num_files+1))
done
echo "$num_files files in folder"

dims=()
num_dim=0
dimension="$dimension "
for (( i=0; i<${#dimension}; i++ )); do
    if  [ "${dimension:$i:1}" = " " ]
        then
            num_dim=$(($num_dim+1))
            dims+=($temp)
            temp=''
        else
            temp="$temp${dimension:$i:1}"
        fi
done

serial_compress_all(){
    for ((i = 0; i < ${#files[@]}; i++))
    do
        echo "${files[i]}"
        szx -z -f -i ${files[i]} -2 ${dims[0]} ${dims[1]} -M FXR -C $CR_bound -T 0.1
    done
}

serial_decompress_all(){
    for ((i = 0; i < ${#files[@]}; i++))
    do
        echo "${files[i]}"
        szx -x -f -i ${files[i]} -s ${files[i]}.szx -2 ${dims[0]} ${dims[1]} -a
    done
}

serial_compress_all

for file in $folder_name/$comp_data_ending
do 
    # do_not_include='log10'
    # if [[ "$file" != *"$do_not_include"* ]]; then
    echo "$file"
    fsize=$(wc -c "$file" | awk '{print $1}')
    flines=$(wc -l "$file" | awk '{print $1}')
    comp_file_sizes+=($fsize)
    # file_num_lines+=($flines)
    # fi
done

# total_raw_bytes=0
# total_comp_bytes=0
# for ((i = 0; i < ${#files[@]}; i++))
# do
#     total_raw_bytes=$(bc <<< $total_raw_bytes+${file_sizes[i]})
#     total_comp_bytes=$(bc <<< $total_comp_bytes+${comp_file_sizes[i]})
#     compresssion_ratio=$(bc <<< "scale=2; ${file_sizes[i]}/${comp_file_sizes[i]}")
#     echo "$compresssion_ratio ${files[i]}" 
#     compresssion_ratios+=($(bc <<< "scale=2; ${file_sizes[i]}/${comp_file_sizes[i]}"))
#     num_files=$((num_files+1))
# done
# echo "$num_files files in folder"

# echo $total_raw_bytes
# echo $total_comp_bytes
# echo $(bc <<< "scale=2; $total_raw_bytes/$total_comp_bytes")

for ((i=0; i<${#files[@]}; i++))
do
    echo "RUNNING: fio --name=write_data --filename=$device --rw=write --bs=128k --size=${comp_file_sizes[i]} --direct=1"
    sudo fio --name=write_data --filename=$device --rw=write --bs=4k --size=${comp_file_sizes[i]} --direct=1
done

for ((i=0; i<${#files[@]}; i++))
do
    echo "RUNNING: fio --name=read_data --filename=$device --rw=read --bs=128k --size=${comp_file_sizes[i]} --direct=1"
    sudo fio --name=read_data --filename=$device --rw=read --bs=4k --size=${comp_file_sizes[i]} --direct=1
done

serial_decompress_all

