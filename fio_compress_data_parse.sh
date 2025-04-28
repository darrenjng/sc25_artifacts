#!/usr/bin/env bash

file_name='fio_output.txt'

while getopts f: flag
do
    case "${flag}" in
        f) file_name=${OPTARG};;
    esac
done

cmp_ms="compression time"
dcmp_ms="compression time"
write_ms="WRITE:"
read_ms="READ:"
ctr=0
while read line; do
    case "$line" in
        # *$cmp_ms*)
        #     if ((ctr < 77))
        #     then
        #         echo $line
        #     fi
        #     ctr=$(($ctr+1))
        # ;;
        *$write_ms*)
            echo $line
        ;;
        *$read_ms*)
            echo $line
        ;;
        *$dcmp_ms*)
            # echo $line
        ;;
    esac
done <"$file_name"