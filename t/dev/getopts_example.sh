#!/bin/bash
 
while getopts ":a:" opt; do
  case $opt in
    a)
      echo "-a was triggered, Parameter: $OPTARG" >&2
OLD_IFS=IFS
IFS=$'\n'
arr=($(cat $OPTARG))
IFS=OLD_IFS
echo ${arr[0]}
echo ${arr[-1]}
echo ${arr[-4]}
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
