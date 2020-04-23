#!/bin/bash
# 
# by John Xu
# For opci CPU load and telemetry data reading
# Version 0.1
#	- Based on readTemp.sh
#	- -c for overall cpu load
#	- -p for pid/program specific cpu load
#	* read sensors temp/humidity, tmp275, als, etc.
#	* read ina220 sensors, specify address
#=========================================================================
TAG="${0##*/}"				#get the base name of itself
############ Functions
Version="0.1"
version()
{
	echo "$TAG version $Version"
}

usage()	#edit
{
	version
	cat << EOF
	USAGE: $TAG [-hvfc] [-p program] [-u username] [-w password] [-b i2cbus] [-i "i2caddr0 i2caddr1 ..."] [-a] <ipaddress>
		-h or --help to display this message
		-v or --version to display version information
		-f or --fieldname to output field names
		-c or --cpu to read cpu load percentage also

		-p or --program specify which program or pid should be checked (the cpu load)
		-u or --user specify the user name for ssh connection, default: ubuntu
		-w or --word specify the password to be used for ssh connection, default: ubuntu
		-a or --address to specify the ipaddress for ssh connection, the switch can be omitted

		-b or --i2cbus to specify i2cbus number (default 6. for 8u2i and cc48smi it should be 5)
		-i or --ina220 to specify reading an ina220 sensor (hex i2c address) Voltage, Current, Power. 
EOF
}

outfieldname()	
{
	local output="Timestamp"
	if [ "$cpuUsage" = "1" ]; then
		output="${output}, CPU_load"
	fi
	if [ "$program" != "" ]; then
		output="${output}, ${program}"
	fi
	if [ "$i2caddr" != "" ]; then
		for addr in ${i2caddr}; do
			output="${output}, V_${addr}, C_${addr}"
		done
	fi

	echo $output
}

convertecbdata()	#edit
{
	local hexint=$(echo $1|cut -b 15,17)
	local data=$((0x${hexint}))
	local hexfrac=$(echo $1|cut -b 18)
	if [ "$hexfrac" == "8" ]; then
		data="${data}.5"
	fi
	echo $data
}

getecb()	#edit
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

convertprttemp()	#edit
{
	local data=$1
	local result=$(($data*1650/65536-400))		#to get 1 digit decimal, multiple the formula with 10
	echo "${result:0:-1}.${result: -1}"			#then display the point before last digit
}

#ecbSensors=("00" "01" "02" "03" "04" "05")
address=
cpuUsage=
field=
program=
username="ubuntu"
password="ubuntu"
i2cbus="6"
i2caddr=

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
        -f | --fieldname )      #outfieldname
								field=1
                                ;;
		-c | --cpu)
								cpuUsage=1 
								;;
		-p | --program)			shift
								program=$1
								;;
		-u | --user)			shift
								username=$1
								;;
		-w | --word)			shift
								password=$1
								;;
		-i | --ina220)			shift
								i2caddr=${1,,}			#to convert all to lower case
								;;
		-b | --i2cbus)			shift
								i2cbus=$1
								;;
		-a | --address)			shift
								address=$1
								;;
        * )                     address=$1
                                
    esac
    shift
done

if [ "$address" = "" ]
then
	usage
	exit
fi

if [ "$field" = 1 ]
then
	outfieldname
	exit
fi

# ssh command, "sshpass -p ubuntu ssh -t ubuntu@192.168.1.19"
sshc="sshpass -p $password ssh -t ${username}@${address}" 
#echo $sshc
output="$(date +"%d-%T")"	

if [ "$cpuUsage" = "1" ]; then
#	message=`$sshc "top -n 2|grep Cpu|tail -n1"`
#	echo $message
	v0=$($sshc "top -n 2|grep Cpu|tail -n1" 2>&1|grep Cpu|awk '{print $2+$4+$6+$10+$12+$14+$16}')
	output="${output}, $v0"
fi

if [ "$program" != "" ]; then
#	"top -n 1 -d 20" 2>&1 |grep 20190|awk '{printf $9 "\n"}'
	v0=$($sshc "top -n 1|grep $program" 2>&1|grep $program|awk '{print $10}')
	output="${output}, $v0"
fi

if [ "$i2caddr" != "" ]; then
#	"cat /sys/class/i2c-dev/i2c-5/device/5-0041/hwmon/hwmon*/curr1_input"
	comm=
#	i2carray=($i2caddr)
#	for addr in ${i2carray[@]}; do
#	i2caddr=${i2caddr,,}			#to convert all to lower case
	for addr in ${i2caddr}; do
		if [ "$comm" != "" ]; then 
			comm="${comm};" 
		fi
		comm="${comm} cat /sys/class/i2c-dev/i2c-${i2cbus}/device/${i2cbus}-00${addr}/hwmon/hwmon*/in1_input; cat /sys/class/i2c-dev/i2c-${i2cbus}/device/${i2cbus}-00${addr}/hwmon/hwmon*/curr1_input"
	done
#	echo $comm
	message=$($sshc $comm 2>&1|grep -vE "Warning|Connection"|tr ',' ';'|tr '\r\n' ', ')  #convert ',' so each data occupy 1 position in CSV output
#	echo $message
#	echo

	output="${output}, $message"
fi

echo $output
