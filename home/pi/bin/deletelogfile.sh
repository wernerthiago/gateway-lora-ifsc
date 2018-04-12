#!/bin/bash
	curl -F "operation=upload" -F "file=@/home/pi/risinghf/packet_forwarder/lora_pkt_fwd/logfile.log" https://iot.sj.ifsc.edu.br/~thiago.werner/log.php
	cd /home/pi/risinghf/packet_forwarder
	file=logfile.log
	minimumsize=90000
	actualsize=$(wc -c <"$file")
	if [ $actualsize -ge $minimumsize ]; then
		cat /dev/null > logfile.log
	fi
