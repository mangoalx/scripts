#!/bin/bash

# 
# by John Xu
# For checking ecb telemetry data, if not available, take log data
# Version 0.1
# 1 need dxp, so export its path
# 2 need pycommander environment, should run in its folder, and pipenv ready
# 3 now removed prompt from pycommander, so cut command is not necessary 
count=0
failed=0
while true
	do  echo "Total cycles:$count, total failures:$failed";count=$(($count+1))
	date +%T
	dxp -a10.1.2.41 -s0 -uadmin -padmin
	sleep 5
	dxp -a10.1.2.41 -s1 -uadmin -padmin
#	python3 pycommander.py -e prod.jsn --id 29493 -c 'su_reboot'
#	adb reboot
	sleep 100
#	speeddata=`python3 pycommander.py -e prod.jsn --id 29493 -c '#tail -n 1 /sdcard/icanvas/*speed.csv'|cut -d' ' -f2`
#	data=`echo $speeddata|cut -d' ' -f1`
#	sleep 2 #wait or pycommander finish
#	data=`python3 pycommander.py -e prod.jsn --id 29493 -c '#tail -n 1 /sdcard/icanvas/*speed.csv'|cut -d' ' -f2`
#	hour=$(date +'%H')
#	echo $hour
#	until [ $hour -ne 19 ]; do echo "current time hour: $hour";sleep 600;hour=$(date +'%H'); done
	adb connect 10.1.3.91
	sleep 5
#	python3 pycommander.py -e prod.jsn --id 29722 -c 'su_shell_cmd:=am broadcast -a com.videri.ecbservice.ECB_GET_CURRENT_TABLE_ACTION --es ECB_GET_CURRENT_TABLE_EXTRA_PATH /sdcard/current_env_table.bin'
	data=`adb shell logcat -d|grep APROM|grep -v icanvas`
	echo $data
#	sleep 5
#	len=`adb -s 10.1.3.91 shell cat /sdcard/current_env_table.bin|wc -m`
#	len=`expr length $data`
#	echo $len
#	if [[ $len -lt 20 ]] 
#	if [[ $len -lt 200 ]] 
	if [[ "$data" != *"APROM"* ]]
	then #python3 pycommander.py -e prod.jsn --id 29493 -c '#logcat -d >> /sdcard/icanvas/logerror.log'
		#python3 pycommander.py -e prod.jsn --id 29493 -c '#dmesg >> /sdcard/icanvas/dmesg.log'
#		adb connect 10.1.3.91
#		adb connect 10.1.0.17
#        sleep 5
		failed=$(($failed+1))
		echo "Captured in loop $count, total failures: $failed"
		echo "$failed*===================================" >> temp/dumpsys.log
		adb -s 10.1.3.91 shell dumpsys >> temp/dumpsys.log
		echo "$failed*===================================" >> temp/dmesg.log
		adb -s 10.1.3.91 shell dmesg >> temp/dmesg.log
		echo "$failed*===================================" >> temp/logcat.log
		adb -s 10.1.3.91 logcat -d >> temp/logcat.log
#		break 
#	else
#		adb -s 10.1.3.91 shell rm /sdcard/current_env_table.bin
#		echo "delete table"
#		sleep 3
	fi
done 

