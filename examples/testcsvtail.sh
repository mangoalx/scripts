#!/bin/bash
count=1
while true
do	
	echo $count
	count=$(($count+1))
	dxp -a10.1.2.42 -s0 -uadmin -padmin
	sleep 60
	dxp -a10.1.2.42 -s1 -uadmin -padmin
	sleep 540
	python3 pycommander.py -e prod.jsn --id 29493 -c '#tail /sdcard/icanvas/*speed.csv'
	read -t 0.1 -n 10000 discard
	read -p "Do you really want to quit? " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]
	then
		break
	fi
done 
