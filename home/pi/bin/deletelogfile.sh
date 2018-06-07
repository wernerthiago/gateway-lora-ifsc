#!/bin/bash
	curl -F "operation=upload" -F "file=@/home/pi/risinghf/packet_forwarder/logfiletest.log" https://iot.sj.ifsc.edu.br/~thiago.werner/logtest.php
	cd /home/pi/risinghf/packet_forwarder
	file=logfiletest.log
	minimumsize=90000
	actualsize=$(wc -c <"$file")
	if [ $actualsize -ge $minimumsize ]; then
		cat /dev/null > logfiletest.log
	fi
