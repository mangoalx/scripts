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
# 	- Add cpu usage reading
#	- Add parameter intrepreter
#	- Add help message
# Version 0.4
#	- Get cpu usage from top instead of dumpsys cpuinfo
#	- Add parameter -d for top delay time, 3 as default
#	- Show version information
# Version 0.41
#	- Add field name for each	

############ Functions
version()
{
	echo "readTemp.sh version 0.4"
}
usage()
{
	version
#	echo "readTemp.sh version 0.4"
    echo "usage: readtemp [[-h] | [[-c] [-d delay] [[-s] SerialNo]]]"
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-f or --fieldname to output field names"
	echo "-c or --cpu to read cpu load percentage also"
	echo "-d or --delay to specify how long to wait before reading data"
	echo "              When -c is present, it is delay time for top, default as 3"
	echo "SerialNo to specify the device to read from. -s or --serial can be omitted"
}

outfieldname()
{
	echo "Timestamp,A53_3,A53_0,A53_1,A53_2,A57_2,A57_0,A57_1,A57_3,A53-A57,GPU1,GPU2,Modem,Hexagon1,Hexagon2,Camera,MDSS,CPU_load"
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
        -f | --fieldname )      outfieldname
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
		adbc="adb shell"
	else adbc="adb -s $serial shell"
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

