#!/bin/bash

# 
# by John Xu
# For dumping sensor data via adb connection
# Version 0.1
#
#	* Error check (result contains digit number only means success)
#	* Check different sensors according to part model name or part no.
#	* Create table or list for dumping for each model
#	* Auto check part no - 
#		adb shell getprop|grep partnumber
#		[ro.boot.partnumber]: [VEN065FDM80]


############ Functions
version()
{
	echo "adbsensordump.sh version 0.1"
}
usage()
{
	version
    echo "usage: adbsensordump [[-h] | [-v] | [-s serial] [-d deviceType]]"
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-s or --serial to specify device serial No., "
	echo "-d or --device to specify the device type ... 6U, 6XT, QSM, etc."
}
argError()
{
	echo "********Argument error."
	usage
}


#-------------------------------------------------

TAG="${0##*/}"					#Assuming $0 is a file name, it will give you the file name without the leading path. 
								#It works the same way as the basename command.

error_check() {
    # Execute and handle success/error
    MESSAGE=$(eval "$adbc ${1}" 2>&1)
	if [ -n "$2" ]
	then
#		echo $MESSAGE
#	else
		len=${#MESSAGE}					# Get the message length. if it is 0 or longer than 8 chars, there is an error ...
		let "len-=2"
		ndigits=`echo $MESSAGE | grep -P -o '\d' | wc -l`
#		echo "$len ---- $ndigits"
		if [[ $ndigits -lt 1 || $len -gt $ndigits ]]
		then
			$adbc log -p e -t "${TAG}" "Command: ${1} Error: ${MESSAGE}"
			echo "${2}: ERROR -- ${MESSAGE}"
			let "errorCount++"
		else
			$adbc log -p d -t "${TAG}" "Command: ${1} Value: ${MESSAGE}"
			echo "${2}: SUCCESS -- ${MESSAGE}"
		fi
	fi
#    MESSAGE="$(eval ${1} 2>&1)"
#    if [ $? -ne 0 ]; then
#        log -p e -t "${TAG}" "Command: ${1} Error: ${MESSAGE}"
#        echo "${2}: ERROR -- ${MESSAGE}"
#    else
#        log -p d -t "${TAG}" "Command: ${1} Value: ${MESSAGE}"
#        echo "${2}: SUCCESS -- ${MESSAGE}"
#    fi
}

################################
serial=
device=
MESSAGE=""						# This will be used to pass result from sub-function
errorCount=0					# This is used to count how many error occurred

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
		-s | --serial)			shift
								serial=$1
								;;
		-d | --device)			
								shift
								device=$1
								;;
        * ) 					argError
								exit
                                
    esac
    shift
done

I2C_BASE_PATH="/sys/class/i2c-dev/i2c-9/device/9-00"

if [ -z "$serial" ]
	then
#		adbc="adb wait-for-device shell"
		adbc="adb shell"
	else adbc="adb -s $serial shell"
fi



# Read from 1-wire temperature sensor
error_check "head -n 1 /sys/bus/w1/devices/w1_bus_master2/w1_master_slaves"			#got device folder name
error_check "cat /sys/bus/w1/devices/w1_bus_master2/${MESSAGE//[$'\t\r\n']}/w1_slave" #get data
#echo $MESSAGE
MESSAGE=$(sed -n '{N;s/^.*YES.*t=\([-[:digit:]]*\).*/\1/p}' <<< "$MESSAGE")				#grab the data
#echo "data: $MESSAGE"
error_check "echo $MESSAGE" "w1_slave-0x19-temperature"
#error_check "sed -n '{N;s/^.*YES.*t=\([-[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master2/`head -n 1 /sys/bus/w1/devices/w1_bus_master2/w1_master_slaves`/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"		#By John, add '-' before digit to allow <0 number
#error_check "sed -n '{N;s/^.*YES.*t=\([[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master1/`head -n 1 /sys/bus/w1/devices/w1_bus_master1/w1_master_slaves`/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"
# Read from mcp9808s
error_check "cat ${I2C_BASE_PATH}1c/temp1_input"    "mcp9808-0x1c-temperature"
error_check "cat ${I2C_BASE_PATH}1e/temp1_input"    "mcp9808-0x1e-temperature"
# Read from hdc1080
error_check "cat ${I2C_BASE_PATH}40/temp1_input"    "hdc1080-0x40-temperature"
error_check "cat ${I2C_BASE_PATH}40/humrel1_input"  "hdc1080-0x40-humidity"
# Read from ina220s
error_check "cat ${I2C_BASE_PATH}41/in1_input"      "ina220-0x41-voltage"
error_check "cat ${I2C_BASE_PATH}41/curr1_input"    "ina220-0x41-current"
error_check "cat ${I2C_BASE_PATH}41/power1_input"   "ina220-0x41-power"
error_check "cat ${I2C_BASE_PATH}42/in1_input"      "ina220-0x42-voltage"
error_check "cat ${I2C_BASE_PATH}42/curr1_input"    "ina220-0x42-current"
error_check "cat ${I2C_BASE_PATH}42/power1_input"   "ina220-0x42-power"
error_check "cat ${I2C_BASE_PATH}45/in1_input"      "ina220-0x45-voltage"
error_check "cat ${I2C_BASE_PATH}45/curr1_input"    "ina220-0x45-current"
error_check "cat ${I2C_BASE_PATH}45/power1_input"   "ina220-0x45-power"
error_check "cat ${I2C_BASE_PATH}46/in1_input"      "ina220-0x46-voltage"
error_check "cat ${I2C_BASE_PATH}46/curr1_input"    "ina220-0x46-current"
error_check "cat ${I2C_BASE_PATH}46/power1_input"   "ina220-0x46-power"
error_check "cat ${I2C_BASE_PATH}4a/in1_input"      "ina220-0x4a-voltage"
error_check "cat ${I2C_BASE_PATH}4a/curr1_input"    "ina220-0x4a-current"
error_check "cat ${I2C_BASE_PATH}4a/power1_input"   "ina220-0x4a-power"
error_check "cat ${I2C_BASE_PATH}4b/in1_input"      "ina220-0x4b-voltage"
error_check "cat ${I2C_BASE_PATH}4b/curr1_input"    "ina220-0x4b-current"
error_check "cat ${I2C_BASE_PATH}4b/power1_input"   "ina220-0x4b-power"
error_check "cat ${I2C_BASE_PATH}4c/in1_input"      "ina220-0x4c-voltage"
error_check "cat ${I2C_BASE_PATH}4c/curr1_input"    "ina220-0x4c-current"
error_check "cat ${I2C_BASE_PATH}4c/power1_input"   "ina220-0x4c-power"
# Read from lcc600
error_check "cat ${I2C_BASE_PATH}5e/in1_input"      "lcc600-0x5e-ac-voltage"
error_check "cat ${I2C_BASE_PATH}5e/in2_input"      "lcc600-0x5e-24-voltage"
error_check "cat ${I2C_BASE_PATH}5e/curr1_input"    "lcc600-0x5e-current"
error_check "cat ${I2C_BASE_PATH}5e/power1_input"   "lcc600-0x5e-power"
error_check "cat ${I2C_BASE_PATH}5e/temp1_input"    "lcc600-0x5e-temperature1"
error_check "cat ${I2C_BASE_PATH}5e/temp2_input"    "lcc600-0x5e-temperature2"
error_check "cat ${I2C_BASE_PATH}5e/temp3_input"    "lcc600-0x5e-temperature3"
# Read from isl29023
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_illuminance0_input"  "isl29023-0x44-illuminance"
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_intensity_ir_raw"    "isl29023-0x44-intensity_ir_raw"
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_proximity_raw"       "isl29023-0x44-proximity_raw"
if((errorCount == 0))
then
	echo "Test passed>>>>>>>>"
else
	echo "Test failed, $errorCount errors encountered"
	exit 1
fi


