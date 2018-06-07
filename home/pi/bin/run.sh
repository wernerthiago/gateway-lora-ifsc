#!/bin/bash
	while true; do
	/home/pi/risinghf/lora_gateway/reset_lgw.sh start 7
	rmmod spi_bcm2835
	modprobe spi_bcm2835
	cd /home/pi/risinghf/packet_forwarder/lora_pkt_fwd
	./lora_pkt_fwd >> /home/pi/risinghf/packet_forwarder/logfiletest.log &
	wait $!
	sleep 1
	done
	exit
