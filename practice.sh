#!/bin/bash
<<<<<<< HEAD
# 
# by John Xu
# For DPC4xx device CPU temperature reading
# Version 0.2
#	put all output in single line and seperate each data with a comma, so it will be easily imported into excel
# 	tr command in each line is used to remove carriage return from each reading output
#	date +'%d-%T'
#
#   To specify a device to be read, use its serial number as parameter
# Version 0.3
# 	- Add cpu usage reading
#	- Add parameter intrepreter
#	- Add help message
# Version 0.4
#	- Get cpu usage from top instead of dumpsys cpuinfo
#	- Add parameter -d for top delay time, 3 as default
#	- Show version information
# Version 0.41
#	- Wait for adb device when it is not ready before trying to read data
#	* Print sensor names when -n --name switch is present
#	* Only read A57 / A53 sensors when specified -7/--A57 -3/--A53 
# Version 0.5
#	* Add header line option
#	* Allow read environment temperatures
#	

############ Functions
version()
{
	echo "readTemp.sh version 0.5"
}
usage()
{
	version
#	echo "readTemp.sh version 0.4"
    echo "usage: readtemp [[-h] [-v] [-H] | [[-c] [-e] [-d delay] [[-s] SerialNo]]]"
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-c or --cpu to read cpu load percentage also"
	echo "-H or --Header to output a header line"
	echo "-e or --environment to read environment temperature"
	echo "-d or --delay to specify how long to wait before reading data"
	echo "              When -c is present, it is delay time for top, default as 3"
	echo "SerialNo to specify the device to read from. -s or --serial can be omitted"
	echo "Please note that the adb command will wait for device to be ready if it is not yet"
}


serial= 
cpuUsage=
topDelay=3			#top command by default delay 3 seconds

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
		-c | --cpu)
								cpuUsage=1 
								;;
		-d | --delay)			shift
								topDelay=$1
								;;
		-s | --serial)			shift
								serial=$1
								;;
        * )                     serial=$1
                                
    esac
    shift
done

if [ -z "$serial" ]
	then
		adbc="adb wait-for-device shell"
	else adbc="adb -s $serial wait-for-device shell"
fi

if [ "$cpuUsage" = "1" ]; then
		v0=$($adbc top -d $topDelay -m 1 -n 1|grep %,|sed -e 's/[^0-9 ]//g'|awk '{print $1+$2+$3+$4"%"}')
else
	sleep $topDelay
fi
		v11=$($adbc cat /sys/devices/virtual/thermal/thermal_zone11/temp | tr -d '\r')
		v8=$($adbc cat /sys/devices/virtual/thermal/thermal_zone8/temp | tr -d '\r')
		v9=$($adbc cat /sys/devices/virtual/thermal/thermal_zone9/temp | tr -d '\r')
		v10=$($adbc cat /sys/devices/virtual/thermal/thermal_zone10/temp | tr -d '\r')
		v16=$($adbc cat /sys/devices/virtual/thermal/thermal_zone16/temp | tr -d '\r')
		v14=$($adbc cat /sys/devices/virtual/thermal/thermal_zone14/temp | tr -d '\r')
		v15=$($adbc cat /sys/devices/virtual/thermal/thermal_zone15/temp | tr -d '\r')
		v7=$($adbc cat /sys/devices/virtual/thermal/thermal_zone7/temp | tr -d '\r')
		v1=$($adbc cat /sys/devices/virtual/thermal/thermal_zone1/temp | tr -d '\r')
		v13=$($adbc cat /sys/devices/virtual/thermal/thermal_zone13/temp | tr -d '\r')
		v12=$($adbc cat /sys/devices/virtual/thermal/thermal_zone12/temp | tr -d '\r')
		v6=$($adbc cat /sys/devices/virtual/thermal/thermal_zone6/temp | tr -d '\r')
		v2=$($adbc cat /sys/devices/virtual/thermal/thermal_zone2/temp | tr -d '\r')
		v3=$($adbc cat /sys/devices/virtual/thermal/thermal_zone3/temp | tr -d '\r')
		v4=$($adbc cat /sys/devices/virtual/thermal/thermal_zone4/temp | tr -d '\r')
		v5=$($adbc cat /sys/devices/virtual/thermal/thermal_zone5/temp | tr -d '\r')

#	else
#		adb -s "$serial" shell dumpsys cpuinfo|grep TOTAL| read v0 _ 
#		v11=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone11/temp | tr -d '\r')
#		v8=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone8/temp | tr -d '\r')
#		v9=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone9/temp | tr -d '\r')
#		v10=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone10/temp | tr -d '\r')
#		v16=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone16/temp | tr -d '\r')
#		v14=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone14/temp | tr -d '\r')
#		v15=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone15/temp | tr -d '\r')
#		v7=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone7/temp | tr -d '\r')
#		v1=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone1/temp | tr -d '\r')
#		v13=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone13/temp | tr -d '\r')
#		v12=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone12/temp | tr -d '\r')
#		v6=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone6/temp | tr -d '\r')
#		v2=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone2/temp | tr -d '\r')
#		v3=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone3/temp | tr -d '\r')
#		v4=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone4/temp | tr -d '\r')
#		v5=$(adb -s "$serial" shell cat /sys/devices/virtual/thermal/thermal_zone5/temp | tr -d '\r')

#fi
if [ "$cpuUsage" = "1" ]; then
#		v0=$($adbc dumpsys cpuinfo|grep TOTAL|cut -f 1 -d " ")
#		v0=$($adbc top -d $topDelay -m 1 -n 1|grep %,|sed -e 's/[^0-9 ]//g'|awk '{print $1+$2+$3+$4"%"}')
		echo $(date +"%d-%T"),$v11,$v8,$v9,$v10,$v16,$v14,$v15,$v7,$v1,$v13,$v12,$v6,$v2,$v3,$v4,$v5,$v0
else
#	sleep $topDelay
	echo $(date +"%d-%T"),$v11,$v8,$v9,$v10,$v16,$v14,$v15,$v7,$v1,$v13,$v12,$v6,$v2,$v3,$v4,$v5
fi
=======

# 
# by John Xu
# For checking ecb telemetry data, if not available, take log data
# Version 0.1
# 1 need dxp, so export its path
# 2 need pycommander environment, should run in its folder, and pipenv ready
# 3 now removed prompt from pycommander, so cut command is not necessary 
count=0
failed=0
canvasIP="10.1.0.17"
canvasID="29493"
ibootIP="10.1.2.42"
adbs="adb -s $canvasIP"

while true
	do  echo "Total cycles:$count, total failures:$failed";count=$(($count+1))
	date +%T
#	dxp -a10.1.2.41 -s0 -uadmin -padmin
	dxp -a$ibootIP -s0 -uadmin -padmin
	sleep 5
#	dxp -a10.1.2.41 -s0 -uadmin -padmin
	dxp -a$ibootIP -s1 -uadmin -padmin
#	python3 pycommander.py -e prod.jsn --id 29493 -c 'su_reboot'
#	adb reboot
	sleep 150
#	speeddata=`python3 pycommander.py -e prod.jsn --id 29493 -c '#tail -n 1 /sdcard/icanvas/*speed.csv'|cut -d' ' -f2`
#	data=`echo $speeddata|cut -d' ' -f1`
#	sleep 2 #wait or pycommander finish
#	data=`python3 pycommander.py -e prod.jsn --id 29493 -c '#tail -n 1 /sdcard/icanvas/*speed.csv'|cut -d' ' -f2`
	hour=$(date +'%H')
#	echo $hour
	until [ $hour -ne 19 ]; do echo "current time hour: $hour";sleep 600;hour=$(date +'%H'); done
#	adb connect $canvasIP
#	adb connect 10.1.3.91
	sleep 5
	loop=1;while true
	do response=`python3 pycommander.py -e prod.jsn --id $canvasID -c 'su_shell_cmd:=am broadcast -a com.videri.ecbservice.ECB_GET_CURRENT_TABLE_ACTION --es ECB_GET_CURRENT_TABLE_EXTRA_PATH /sdcard/current_env_table.bin'|grep completed`
		echo $response
		if [[ "$response" == *"completed"* ]]
		  then break
		fi
		loop=$(($loop+1));if [[ $loop -gt 10 ]]; then break; fi;
		echo "Retry pycommander $loop ..."
		sleep 10
	done
	if [[ "$response" != *"completed"* ]]; then echo "py_commander_error";continue; fi
#	python3 pycommander.py -e prod.jsn --id $canvasID -c 'su_shell_cmd:=am broadcast -a com.videri.ecbservice.ECB_GET_CURRENT_TABLE_ACTION --es ECB_GET_CURRENT_TABLE_EXTRA_PATH /sdcard/current_env_table.bin'|grep completed
#	python3 pycommander.py -e prod.jsn --id 29722 -c 'su_shell_cmd:=am broadcast -a com.videri.ecbservice.ECB_GET_CURRENT_TABLE_ACTION --es ECB_GET_CURRENT_TABLE_EXTRA_PATH /sdcard/current_env_table.bin'|grep completed
#	data=`adb shell logcat -d|grep APROM|grep -v icanvas`
#	echo $data
	loop=1;while true;do message=`adb connect 10.1.0.17`;if [[ "$message" == *"connected"* ]]; then break; else echo "retry $loop"; python3 pycommander.py -e prod.jsn --id $canvasID -c 'su_adb_wifi:=5555'; fi;loop=$(($loop+1));if [[ $loop -gt 10 ]]; then break; fi; sleep 10;done
	if [[ "$message" != *"connected"* ]]; then echo "adb_connection_error";continue; else echo "adb connected"; fi
	sleep 5
	$adbs shell logcat -d|grep APROM		#$adbs shell logcat -d|grep APROM|grep -v icanvas
	len=`$adbs shell cat /sdcard/current_env_table.bin|wc -m`
#	len=`adb -s 10.1.3.91 shell cat /sdcard/current_env_table.bin|wc -m`
#	len=`expr length $data`
	echo $len
#	if [[ $len -lt 20 ]] 
	if [[ $len -lt 200 ]] 
#	if [[ "$data" != *"APROM"* ]]
	then #python3 pycommander.py -e prod.jsn --id 29493 -c '#logcat -d >> /sdcard/icanvas/logerror.log'
		#python3 pycommander.py -e prod.jsn --id 29493 -c '#dmesg >> /sdcard/icanvas/dmesg.log'
#		adb connect 10.1.3.91
#		adb connect 10.1.0.17
#        sleep 5
		failed=$(($failed+1))
		echo "Captured in loop $count, total failures: $failed"
		echo "$failed*===================================" >> temp/dumpsys.log
		$adbs shell dumpsys >> temp/dumpsys.log
		echo "$failed*===================================" >> temp/dmesg.log
		$adbs shell dmesg >> temp/dmesg.log
		echo "$failed*===================================" >> temp/logcat.log
		$adbs logcat -d >> temp/logcat.log
#		break 
	else
		$adbs shell rm /sdcard/current_env_table.bin
		echo "delete table"
		sleep 3
	fi
done 
>>>>>>> dev

