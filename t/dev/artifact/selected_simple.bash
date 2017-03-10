#!/bin/bash

source $(dirname "$SCRIPT")/../../selected

PS3='choice number: '
selected "$@"
echo $PS3
