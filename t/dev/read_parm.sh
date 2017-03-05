#!/bin/sh

#while IFS= read -r; do
#    arr+=("$REPLY")
#done
OLD_IFS=IFS
IFS=$'\n'
@=($(cat))
IFS=OLD_IFS
echo ${@[0]}
echo ${@[-1]}
echo ${@[-4]}
