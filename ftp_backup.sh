#!/bin/bash

lftp -c "
open ftp://192.168.1.1:21
mirror --reverse --delete --parallel /home/christian/c /volume(sda1)/c
"

