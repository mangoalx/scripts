#!/bin/bash
#/system/bin/sh
# 
# by John Xu
# For DPC4xx new tib-2b lcc600 connection test
# Version 0.1
#	put all output in single line and seperate each data with a comma, so it will be easily imported into excel
# 	tr command in each line is used to remove carriage return from each reading output
#	date +'%d-%T'
#	- Add parameter -d for top delay time, 3 as default
#	- Show version information
#
# Version 0.2
#    adb version, running on pc
############ Functions
version()
{
	echo "readlcc600.sh version 0.1"
}
usage()
{
	version
#	echo "readlcc600.sh version 0.4"
    echo "usage: readlcc600 "
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-H or --header to output header"
	echo "-9 to read device on i2c bus 9"
	echo "SerialNo to specify the device to read from. -s or --serial can be omitted"
}
header()
{
	echo "Time,curr1_input,in1_input,in2_input,power1_input,temp1_input,temp2_input,temp3_input"
}

i2cbus= 
serial= 
while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
        -H | --header )        	header
                                exit
                                ;;
		-9 )					i2cbus=9
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

#echo $i2cbus
if [ "$i2cbus" = "9" ]; then

	v0=$($adbc cat /sys/class/i2c-dev/i2c-9/device/9-005e/curr1_input | tr -d '\r')
	v1=$($adbc cat /sys/class/i2c-dev/i2c-9/device/9-005e/in1_input | tr -d '\r')
	v2=$($adbc cat /sys/class/i2c-dev/i2c-9/device/9-005e/in2_input | tr -d '\r')
	v3=$($adbc cat /sys/class/i2c-dev/i2c-9/device/9-005e/power1_input | tr -d '\r')
	v4=$($adbc cat /sys/class/i2c-dev/i2c-9/device/9-005e/temp1_input | tr -d '\r')
	v5=$($adbc cat /sys/class/i2c-dev/i2c-9/device/9-005e/temp2_input | tr -d '\r')
	v6=$($adbc cat /sys/class/i2c-dev/i2c-9/device/9-005e/temp3_input | tr -d '\r')
else
	v0=$($adbc cat /sys/class/i2c-dev/i2c-7/device/7-005e/curr1_input | tr -d '\r')
	v1=$($adbc cat /sys/class/i2c-dev/i2c-7/device/7-005e/in1_input | tr -d '\r')
	v2=$($adbc cat /sys/class/i2c-dev/i2c-7/device/7-005e/in2_input | tr -d '\r')
	v3=$($adbc cat /sys/class/i2c-dev/i2c-7/device/7-005e/power1_input | tr -d '\r')
	v4=$($adbc cat /sys/class/i2c-dev/i2c-7/device/7-005e/temp1_input | tr -d '\r')
	v5=$($adbc cat /sys/class/i2c-dev/i2c-7/device/7-005e/temp2_input | tr -d '\r')
	v6=$($adbc cat /sys/class/i2c-dev/i2c-7/device/7-005e/temp3_input | tr -d '\r')
fi

echo $(date +"%d-%T"),$v0,$v1,$v2,$v3,$v4,$v5,$v6

