#!/bin/bash

filename="/tmp/c_$(date +%Y%m%dT%H%M%S).tar"

tar -cpf $filename -C $HOME c

lftp -c "
open ftp://192.168.1.1:21
cd volume(sda1)
put -E $filename
"

