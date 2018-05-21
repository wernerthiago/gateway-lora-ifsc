#!/bin/bash

ping -q -w 1 -c 1 8.8.8.8 > /dev/null
while [ $? -ne 0 ]; do
   ping -q -w 1 -c 1 8.8.8.8 > /dev/null
done;

wget "https://iot.sj.ifsc.edu.br/~thiago.werner/raspip.php?ip=`hostname -I`" -O /dev/null -o /dev/null
