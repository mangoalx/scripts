#!/bin/bash
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
# 	* Add cpu usage reading
#	* Add parameter intrepreter
#	* Add help message

############ Functions
usage()
{
    echo "usage: readTemp.sh [[-h] | [[-c] [SerialNo]]]"
	echo "-h or --help to display this message"
	echo "-c or --cpu to read cpu load percentage also"
	echo "SerialNo to specify the device to read from"
}


serial= 
cpuUsage=

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
		-c | --cpu)
								cpuUsage=1 
								;;
        * )                     serial=$1
                                
    esac
    shift
done

if [ -z "$serial" ]
	then
		adbc="adb shell"
	else adbc="adb -s $serial shell"
fi
#		echo $adbc
		v11=$($adbc cat /sys/devices/virtual/thermal/thermal_zone11/temp | tr -d '\r')
#		echo $v0,$v11
#exit
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
		v0=$($adbc dumpsys cpuinfo|grep TOTAL|cut -f 1 -d " ")
		echo $(date +"%d-%T"),$v11,$v8,$v9,$v10,$v16,$v14,$v15,$v7,$v1,$v13,$v12,$v6,$v2,$v3,$v4,$v5,$v0
else
	echo $(date +"%d-%T"),$v11,$v8,$v9,$v10,$v16,$v14,$v15,$v7,$v1,$v13,$v12,$v6,$v2,$v3,$v4,$v5
fi

