#!/bin/bash
#
# 
# Should check if $1 exists then use -s option
#When testing bootup temperature, should wait for adb ready
adb wait-for-device

date +'%H:%M:%S'
if [ -z "$1" ]
	then
		adb shell cat /sys/devices/virtual/thermal/thermal_zone11/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone8/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone9/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone10/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone16/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone14/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone15/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone7/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone1/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone13/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone12/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone6/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone2/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone3/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone4/temp
		adb shell cat /sys/devices/virtual/thermal/thermal_zone5/temp

	else
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone11/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone8/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone9/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone10/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone16/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone14/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone15/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone7/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone1/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone13/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone12/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone6/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone2/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone3/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone4/temp
		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone5/temp
fi

