#!/system/bin/sh
#
# This script is used to run on DUT and record core temperature when startup
#
# Destination filename can be assigned as a parameter
if [ -z "$1" ]
	then filename="/data/temp/tempdata.txt"
	else filename="$1"
fi

# Mark a new reading start here
echo "New reading start ... ">>$filename

# Read 50 times
# for(( i=0; i<50; i++ ))
i=0; while [ $(($i)) -le 49 ]; 
	do i=$(($i + 1))
		echo "read $i" >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone11/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone8/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone9/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone10/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone16/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone14/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone15/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone7/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone1/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone13/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone12/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone6/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone2/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone3/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone4/temp >> $filename
		cat /sys/devices/virtual/thermal/thermal_zone5/temp >> $filename
# Wait for 5 seconds before read next data
		sleep 1
	done
			

