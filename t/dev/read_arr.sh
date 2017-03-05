#!/bin/sh

#while IFS= read -r; do
#    arr+=("$REPLY")
#done
OLD_IFS=IFS
IFS=$'\n'
arr=($(cat))
IFS=OLD_IFS
echo ${arr[0]}
echo ${arr[-1]}
echo ${arr[-4]}
