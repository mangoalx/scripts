#!/bin/bash

# 
# by John Xu
# For checking ecb telemetry data, if not available, take log data
# Version 0.2
# - add error check to ensure portal command and adb connect command are succeesseful          
# 1 need dxp, so export its path
# 2 need pycommander environment, should run in its folder, and pipenv ready
# 
count=0
failed=0

while true
	do  echo "Total cycles:$count, total failures:$failed";count=$(($count+1))
	date +%T
	while true
	do speeddata=`python3 pycommander.py -e prod.jsn --id 36754 -c 'su_reboot'`
		if [[ "$speeddata" == *"booting"* ]]
		  then break
		fi
		echo "pycommand error: $speeddata"
		sleep 10
	done
#	dxp -a10.1.2.42 -s0 -uadmin -padmin
#	sleep 30
#	dxp -a10.1.2.42 -s1 -uadmin -padmin
	sleep 120

#	avoid sending portal command at 19h, error could occur
#	hour=$(date +'%H')
#	echo $hour
#	until [ $hour -ne 19 ]; do echo "current time hour: $hour";sleep 600;hour=$(date +'%H'); done
	
	while true
	do speeddata=`python3 pycommander.py -e prod.jsn --id 36754 -c '#tail -n 1 /sdcard/icanvas/*speed.csv'`
		if [[ "$speeddata" == *"2019-1"* ]]
		  then break
		fi
		echo $speeddata
		sleep 10
	done
	data=`echo $speeddata|cut -d' ' -f2`
	sleep 2 #wait for pycommander finish
	echo $data
	len=`expr length $data`
	echo $len
	if [[ $len -lt 40 ]] 
	then
		failed=$(($failed+1))
		echo "Captured in loop $count, total failures: $failed"

		#python3 pycommander.py -e prod.jsn --id 29493 -c '#logcat -d >> /sdcard/icanvas/logerror.log'
		#python3 pycommander.py -e prod.jsn --id 29493 -c '#dmesg >> /sdcard/icanvas/dmesg.log'
		#while true;do message=`adb connect 10.1.0.17`;if [[ "$message" == *"connected"* ]]; then break; fi;date +'%T';sleep 10;done 
#		adb connect 10.1.0.17
    #    sleep 5
	#	echo "$failed===================================" >> temp/dumpsys6u.log
	#	adb -s 10.1.0.17 shell dumpsys >> temp/dumpsys6u.log
	#	echo "$failed===================================" >> temp/dmesg6u.log
	#	adb -s 10.1.0.17 shell dmesg >> temp/dmesg6u.log
	#	echo "$failed===================================" >> temp/logcat6u.log
	#	adb -s 10.1.0.17 logcat -d >> temp/logcat6u.log
#		break 
	fi
done 

