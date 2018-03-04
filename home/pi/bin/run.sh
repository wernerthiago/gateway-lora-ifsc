#!/bin/bash
	/home/pi/risinghf/lora_gateway/reset_lgw.sh start 7
	cd /home/pi/risinghf/packet_forwarder/lora_pkt_fwd
	./lora_pkt_fwd &
