#!/bin/bash
while true; do
	/home/pi/risinghf/lora_gateway/reset_lgw.sh start 7
	cd /home/pi/risinghf/packet_forwarder/lora_pkt_fwd
	./lora_pkt_fwd >> /home/pi/risinghf/packet_forwarder/logfile.log &
	wait $!
	sleep 1
done
exit
