ping -q -w 1 -c 1 8.8.8.8 > /dev/null
while [ $? -ne 0 ]; do
   ping -q -w 1 -c 1 8.8.8.8 > /dev/null
done;

cd /home/pi/bin

date '+%A %W %Y %X' &> raspip
hostname -I >> raspip

curl -F "operation=upload" -F "file=@/home/pi/bin/raspip" https://iot.sj.ifsc.edu.br/~thiago.werner/raspip.php
