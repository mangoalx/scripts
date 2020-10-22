#!/bin/bash
# 
# by John Xu
# For DPC4xx device CPU temperature reading
# If sx7 and ecb sensors data are desired, then adb root connection is needed 
#    (you’ll need a userdebug version firmware installed on the device)
#   https://videri.atlassian.net/wiki/spaces/QA/pages/944668705/How+to+read+5U2+6U2+5U+6U+temperature+sensors
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
#	- Add field name for each	
# Version 1.0
#	- Add sx7 temp reading
#	- Add prt hdc1080 temperature reading
#	- Add ecb obs temperature reading (for #U2)
# Version 1.1
#	- version and usage funcs revised
#	- prt reading conversion (1-digit float). Convert prt reading to actual degree value
#		T = (reading/65536)*165-40
#	* allow to specify where to find sx7 and nuvoisp tools
#=========================================================================
TAG="${0##*/}"				#get the base name of itself
############ Functions
Version="1.1"
version()
{
	echo "$TAG version $Version"
}
usage()
{
	version
	cat << EOF
	USAGE: $TAG [-hvfcxpe] [-d <delay>] [[-s] <serialNo>]
		-h or --help to display this message
		-v or --version to display version information
		-f or --fieldname to output field names
		-c or --cpu to read cpu load percentage also
		-x or --sx7 to read sx7 temperature
		-p or --prt to read prt on board temperature
		-e or --ecb to read ecb off board temperature sensors

		-d or --delay to specify how long to wait before reading data
		              When -c is present, it is delay time for top, default as 3
		SerialNo to specify the device to read from. -s or --serial can be omitted
		Please note that the adb command will wait for device to be ready if it is not yet
EOF
}

outfieldname()
{
	local output="Timestamp,A53_3,A53_0,A53_1,A53_2,A57_2,A57_0,A57_1,A57_3,A53-A57,GPU1,GPU2,Modem,Hexagon1,Hexagon2,Camera,MDSS"
	if [ "$cpuUsage" = "1" ]; then
		output="${output},CPU_load"
	fi
	if [ "$sx7" = "1" ]; then
		output="${output},sx7"
	fi
	if [ "$prt" = "1" ]; then
		output="${output},prt"
	fi
	if [ "$ecb" = "1" ]; then
		output="${output},ecb0,ecb1,ecb2,ecb3,ecb4,ecb5"
	fi
#	echo "Timestamp,A53_3,A53_0,A53_1,A53_2,A57_2,A57_0,A57_1,A57_3,A53-A57,GPU1,GPU2,Modem,Hexagon1,Hexagon2,Camera,MDSS,CPU_load,sx7,prt,ecb0,ecb1,ecb2,ecb3,ecb4,ecb5"
	echo $output
}

convertecbdata()
{
	local hexint=$(echo $1|cut -b 15,17)
	local data=$((0x${hexint}))
	local hexfrac=$(echo $1|cut -b 18)
	if [ "$hexfrac" == "8" ]; then
		data="${data}.5"
	fi
	echo $data
}

getecb()
{
	local message=
	case $1 in
		00)	message=$($adbc 'nuvoisp -a "AA 10 00 01 00 00 00" |grep "<=="');;
		01)	message=$($adbc 'nuvoisp -a "AA 10 01 01 00 00 00" |grep "<=="');;
		02)	message=$($adbc 'nuvoisp -a "AA 10 02 01 00 00 00" |grep "<=="');;
		03)	message=$($adbc 'nuvoisp -a "AA 10 03 01 00 00 00" |grep "<=="');;
		04)	message=$($adbc 'nuvoisp -a "AA 10 04 01 00 00 00" |grep "<=="');;
		05)	message=$($adbc 'nuvoisp -a "AA 10 05 01 00 00 00" |grep "<=="');;
		06)	message=$($adbc 'nuvoisp -a "AA 10 06 01 00 00 00" |grep "<=="');;
		*) message=
	esac

#	local message=$($adbc 'nuvoisp -a "AA 10 ${1} 01 00 00 00" |grep "<=="')
#	local message=$($adbc 'nuvoisp -a "AA 10 $1 01 00 00 00"')
#	echo $message >&2
	echo $( convertecbdata "$message" )
}

convertprttemp()
{
	local data=$1
	local result=$(($data*1650/65536-400))		#to get 1 digit decimal, multiple the formula with 10
	echo "${result:0:-1}.${result: -1}"			#then display the point before last digit
}

ecbSensors=("00" "01" "02" "03" "04" "05")
serial= 
cpuUsage=
field=
sx7=
prt=
ecb=
topDelay=3			#top command by default delay 3 seconds

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
        -f | --fieldname )      #outfieldname
                                #exit
								field=1
                                ;;
		-c | --cpu)
								cpuUsage=1 
								;;
		-x | --sx7)
								sx7=1 
								;;
		-p | --prt)
								prt=1 
								;;
		-e | --ecb)
								ecb=1 
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

if [ "$field" = 1 ]
then
	outfieldname
	exit
fi

if [ -z "$serial" ]
	then
		adbc="adb wait-for-device shell"
	else adbc="adb -s $serial wait-for-device shell"
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
	
	output="$(date +"%d-%T"),$v11,$v8,$v9,$v10,$v16,$v14,$v15,$v7,$v1,$v13,$v12,$v6,$v2,$v3,$v4,$v5"	

if [ "$cpuUsage" = "1" ]; then
	v0=$($adbc top -d $topDelay -m 1 -n 1|grep %,|sed -e 's/[^0-9 ]//g'|awk '{print $1+$2+$3+$4"%"}')
	output="${output},$v0"
else
	sleep $topDelay
fi
if [ "$sx7" = "1" ]; then
	hexdata=`$adbc '/cache/sx7-tool -a "5c 01 02 00 00 00 00 00 00"'|grep '<==' |cut -d ' ' -f5 `
#	echo $hexdata
	v0=$((0x${hexdata}))
	output="${output},$v0"
fi
if [ "$prt" = "1" ]; then
	data=$($adbc cat /sys/class/i2c-dev/i2c-9/device/9-0040/temp1_input | tr -d '\r')
	v0=$(convertprttemp $data)			#convert raw data to float temperature degree
	output="${output},$v0"
fi
if [ "$ecb" = "1" ]; then
	ecbreading=
	for t in ${ecbSensors[@]}; do
#		echo $t
		d=$(getecb "$t")
#		echo $d
		ecbreading="${ecbreading},$d"
	done
	output="${output}$ecbreading"
fi

echo $output
