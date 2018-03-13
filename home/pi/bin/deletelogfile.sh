#!/bin/bash
	cd /home/pi/risinghf/packet_forwarder
	find logfile.log -size +3999c -exec cat /dev/null > logfile.log \;
