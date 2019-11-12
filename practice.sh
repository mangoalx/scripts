#!/bin/bash

# 
# by John Xu
# For checking ecb telemetry data, if not available, take log data
# Version 0.1
# 1 need dxp, so export its path
# 2 need pycommander environment, should run in its folder, and pipenv ready
# 3 now removed prompt from pycommander, so cut command is not necessary 
count=1
while true
	do  echo $count;count=$(($count+1))
	date +%T
#	dxp -a10.1.2.42 -s0 -uadmin -padmin
#	sleep 30
#	dxp -a10.1.2.42 -s1 -uadmin -padmin
	python3 pycommander.py -e prod.jsn --id 29493 -c 'su_reboot'
	sleep 120
#	speeddata=`python3 pycommander.py -e prod.jsn --id 29493 -c '#tail -n 1 /sdcard/icanvas/*speed.csv'|cut -d' ' -f2`
#	data=`echo $speeddata|cut -d' ' -f1`
#	sleep 2 #wait or pycommander finish
	data=`python3 pycommander.py -e prod.jsn --id 29493 -c '#tail -n 1 /sdcard/icanvas/*speed.csv'|cut -d' ' -f2`
	echo $data
	len=`expr length $data`
	echo $len
	if [[ $len -lt 20 ]] 
	then #python3 pycommander.py -e prod.jsn --id 29493 -c '#logcat -d >> /sdcard/icanvas/logerror.log'
		#python3 pycommander.py -e prod.jsn --id 29493 -c '#dmesg >> /sdcard/icanvas/dmesg.log'
		adb connect 10.1.0.17
        sleep 5
		adb shell dumpsys >> dumpsys.log
		adb shell dmesg >> dmesg.log
		adb logcat -d >> logcat.log
		break 
	fi
done 

