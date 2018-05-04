if pgrep lora_pkt_fwd
then
	echo "Is Running"
	exit 0
else
	echo "Executing it again"
	cd /home/pi/bin
	./run.sh &
fi

exit 0
