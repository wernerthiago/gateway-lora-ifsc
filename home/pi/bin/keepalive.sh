#!/bin/bash

ping -q -w 1 -c 1 8.8.8.8 > /dev/null
while [ $? -ne 0 ]; do
   ping -q -w 1 -c 1 8.8.8.8 > /dev/null
done;

#ifconfig > /tmp/ifconfig.txt
#curl -i -X POST -H "Content-Type: application/json" http://52.67.57.202:1880/keepalive -d '{"ifconfig" : #"'$( base64 -w 0 /tmp/ifconfig.txt )'"}'
#rm /tmp/ifconfig.txt


wget "https://pji2eng.sj.ifsc.edu.br/~arliones/raspip.php?ip=`hostname -I`" -O /dev/null -o /dev/null

