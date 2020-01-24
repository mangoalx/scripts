#!/system/bin/sh
# 
# by John Xu
# For DPC4xx device CPU temperature reading
# Modified from readTemp.sh Version1.0
#
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
# Version 1.0
#	* Add sx7 temp reading
#	* Add prt hdc1080 temperature reading
#	* Add ecb obs temperature reading (for #U2)

#	# cpu usage is not available because awk is not usable on device
############ Functions
version()
{
	echo "savetemp.sh version 1.0"
}
usage()
{
	version
#	echo "readTemp.sh version 0.4"
    echo "usage: savetemp [[-h] | [[-c] [-d delay] [[-s] SerialNo]]]"
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-f or --fieldname to output field names"
	echo "-c or --cpu to read cpu load percentage also"
	echo "-x or --sx7 to read sx7 temperature"
	echo "-p or --prt to read prt on board temperature"
	echo "-e or --ecb to read ecb off board temperature sensors"

	echo "-d or --delay to specify how long to wait before reading data"	
	echo "              When -c is present, it is delay time for top, default as 3"
#	echo "SerialNo to specify the device to read from. -s or --serial can be omitted"
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
		00)	message=$(nuvoisp -a "AA 10 00 01 00 00 00" |grep "<==");;
		01)	message=$(nuvoisp -a "AA 10 01 01 00 00 00" |grep "<==");;
		02)	message=$(nuvoisp -a "AA 10 02 01 00 00 00" |grep "<==");;
		03)	message=$(nuvoisp -a "AA 10 03 01 00 00 00" |grep "<==");;
		04)	message=$(nuvoisp -a "AA 10 04 01 00 00 00" |grep "<==");;
		05)	message=$(nuvoisp -a "AA 10 05 01 00 00 00" |grep "<==");;
		06)	message=$(nuvoisp -a "AA 10 06 01 00 00 00" |grep "<==");;
		*) message=
	esac

	echo $( convertecbdata "$message" )
}
#using array for ecb sensor reading
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
		-s | --serial)			shift				#I leave it here, but serial will not be used anywhere
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

	v11=$(cat /sys/devices/virtual/thermal/thermal_zone11/temp | tr -d '\r')
	v8=$(cat /sys/devices/virtual/thermal/thermal_zone8/temp | tr -d '\r')
	v9=$(cat /sys/devices/virtual/thermal/thermal_zone9/temp | tr -d '\r')
	v10=$(cat /sys/devices/virtual/thermal/thermal_zone10/temp | tr -d '\r')
	v16=$(cat /sys/devices/virtual/thermal/thermal_zone16/temp | tr -d '\r')
	v14=$(cat /sys/devices/virtual/thermal/thermal_zone14/temp | tr -d '\r')
	v15=$(cat /sys/devices/virtual/thermal/thermal_zone15/temp | tr -d '\r')
	v7=$(cat /sys/devices/virtual/thermal/thermal_zone7/temp | tr -d '\r')
	v1=$(cat /sys/devices/virtual/thermal/thermal_zone1/temp | tr -d '\r')
	v13=$(cat /sys/devices/virtual/thermal/thermal_zone13/temp | tr -d '\r')
	v12=$(cat /sys/devices/virtual/thermal/thermal_zone12/temp | tr -d '\r')
	v6=$(cat /sys/devices/virtual/thermal/thermal_zone6/temp | tr -d '\r')
	v2=$(cat /sys/devices/virtual/thermal/thermal_zone2/temp | tr -d '\r')
	v3=$(cat /sys/devices/virtual/thermal/thermal_zone3/temp | tr -d '\r')
	v4=$(cat /sys/devices/virtual/thermal/thermal_zone4/temp | tr -d '\r')
	v5=$(cat /sys/devices/virtual/thermal/thermal_zone5/temp | tr -d '\r')
	
	output="$(date +"%d-%T"),$v11,$v8,$v9,$v10,$v16,$v14,$v15,$v7,$v1,$v13,$v12,$v6,$v2,$v3,$v4,$v5"	

if [ "$cpuUsage" = "1" ]; then
	v0=$(top -d $topDelay -m 1 -n 1|grep %,|sed -e 's/[^0-9 ]//g'|awk '{print $1+$2+$3+$4"%"}')
	output="${output},$v0"
else
	sleep $topDelay
fi
if [ "$sx7" = "1" ]; then
	hexdata=`/cache/sx7-tool -a "5c 01 02 00 00 00 00 00 00"|grep '<==' |cut -d ' ' -f5 `
#	echo $hexdata
	v0=$((0x${hexdata}))
	output="${output},$v0"
fi
if [ "$prt" = "1" ]; then
	v0=$(cat /sys/class/i2c-dev/i2c-9/device/9-0040/temp1_input | tr -d '\r')
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
