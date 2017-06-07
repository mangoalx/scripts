#!/bin/bash
# 
# by John Xu
# For DPC4xx device CPU temperature reading
# Version 0.2
#	put all output in single line and seperate each data with a comma, so it will be easily imported into excel
# 	tr command in each line is used to remove carriage return from each reading output
#	date +'%d-%T'
#
# To specify a device to be read, use its serial number as parameter	
if [ -z "$1" ]
	then
		v11=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone11/temp | tr -d '\r')
		v8=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone8/temp | tr -d '\r')
		v9=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone9/temp | tr -d '\r')
		v10=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone10/temp | tr -d '\r')
		v16=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone16/temp | tr -d '\r')
		v14=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone14/temp | tr -d '\r')
		v15=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone15/temp | tr -d '\r')
		v7=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone7/temp | tr -d '\r')
		v1=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone1/temp | tr -d '\r')
		v13=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone13/temp | tr -d '\r')
		v12=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone12/temp | tr -d '\r')
		v6=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone6/temp | tr -d '\r')
		v2=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone2/temp | tr -d '\r')
		v3=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone3/temp | tr -d '\r')
		v4=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone4/temp | tr -d '\r')
		v5=$(adb shell cat /sys/devices/virtual/thermal/thermal_zone5/temp | tr -d '\r')

	else
		v11=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone11/temp | tr -d '\r')
		v8=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone8/temp | tr -d '\r')
		v9=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone9/temp | tr -d '\r')
		v10=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone10/temp | tr -d '\r')
		v16=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone16/temp | tr -d '\r')
		v14=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone14/temp | tr -d '\r')
		v15=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone15/temp | tr -d '\r')
		v7=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone7/temp | tr -d '\r')
		v1=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone1/temp | tr -d '\r')
		v13=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone13/temp | tr -d '\r')
		v12=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone12/temp | tr -d '\r')
		v6=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone6/temp | tr -d '\r')
		v2=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone2/temp | tr -d '\r')
		v3=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone3/temp | tr -d '\r')
		v4=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone4/temp | tr -d '\r')
		v5=$(adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone5/temp | tr -d '\r')

fi
echo $(date +"%d-%T"),$v11,$v8,$v9,$v10,$v16,$v14,$v15,$v7,$v1,$v13,$v12,$v6,$v2,$v3,$v4,$v5
