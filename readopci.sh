#!/bin/bash
# 
# by John Xu
# For opci CPU load and telemetry data reading
# Version 0.1
#	- Based on readTemp.sh
#	- -c for overall cpu load
#	- -p for pid/program specific cpu load
#		search for index to find %CPU so get correct value
#	- read sensors temp/humidity, tmp275, als, etc.
#	- read ina220 sensors, specify address
#	* loop reading
#	* delay time setting
#	* option to write to file
# Version 0.12
#	- read cpu temperature when -c is specified, using hwmon0/temp1_input
#	- when ip address is not specified, read data from host (no ssh command needed)
#
#	- find program name at the "command" session, 'bsp' could appear as user
#	- if a program appeared multitimes, plus togather
#	* allow multi program
#=========================================================================
TAG="${0##*/}"				#get the base name of itself
############ Functions
Version="0.12"
version()
{
	echo "$TAG version $Version"
}

usage()	#edit
{
	version
	cat << EOF
	USAGE: $TAG [-hvfc] [-p program] [-u username] [-w password] [-m -t -l] [-b i2cbus] [-i "i2caddr0 i2caddr1 ..."] [-a] [ipaddress]
		-h or --help to display this message
		-v or --version to display version information
		-f or --fieldname to output field names
		-c or --cpu to read cpu load percentage and cpu temperature

		-p or --program specify which program or pid should be checked (for its cpu load)
		-u or --user specify the user name for ssh connection, default: ubuntu
		-w or --word specify the password to be used for ssh connection, default: ubuntu
		-a or --address to specify the ipaddress for ssh connection, the switch can be omitted
				if ipaddress is omitted, read data locally (from host machine)

		-b or --i2cbus to specify i2cbus number (default 6. for 8u2i and cc48smi it should be 5)
		-i or --ina220 to specify i2c addresses of ina220 sensors to be read (hex i2c address) 
		
		-m or --humidity to read temperature/humidity from hdc1080 0x40 
		-t or --temperature to read temperature sensor tmp275 0x48
		-l or --light to read light sensor ALS 0x44
EOF
}

error_check() {
#	if [ "$address" = "" ]
#	then
		MESSAGE="$(eval ${1} 2>&1)"
		echo $MESSAGE
#	else
#			fi
	
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
	if [ "$cpuUsage" = "1" ]; then
		output="${output}, CPU_Temp"
	fi
	if [ "$humidity" = "1" ]; then
		output="${output}, Humi1080, Temp1080"
	fi
	if [ "$temperature" = "1" ]; then
		output="${output}, Tmp275"
	fi
	if [ "$light" = "1" ]; then
		output="${output}, Illuminance, IR_intensity"
	fi
	if [ "$i2caddr" != "" ]; then
		for addr in ${i2caddr}; do
			output="${output}, V_${addr}, I_${addr}"
		done
	fi

	echo $output
}

#index=
wordindex () {
    words=( ${1} )
    for ((i=0; i < ${#words[@]}; i++)); do
#		echo ${words[i]}
        if [[ ${words[i]} == *$2* ]]; then
            echo $i
            break
        fi
    done
}

getIndexOfWord () 			# deprecated, find out the index of a word in a string (word, string)
{
	echo "Entered getIndex"
	echo $1
	echo $2
	strarray=($2)
	cnt=0; for w in "${strarray[@]}"; do
#        [[ $w == "$1" ]] && echo $cnt && break
        [[ $w == "$1" ]] && index=$cnt && break
		echo $w
        ((++cnt))
    done
}
strindex() { 
  x="${1%%$2*}"
  [[ "$x" = "$1" ]] || echo "${#x}"
}

#getWordByIndex()			#

address=
cpuUsage=
field=
program=
username="ubuntu"
password="ubuntu"
i2cbus="6"
i2caddr=
humidity=
temperature=
light=

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
		-m | --humidity)
								humidity=1 
								;;
		-t | --temperature)
								temperature=1 
								;;
		-l | --light)
								light=1 
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

if [ "$field" = 1 ]
then
	outfieldname
	exit
fi

if [ "$address" != "" ]
then
# ssh command, "sshpass -p ubuntu ssh -t ubuntu@192.168.1.19"
	sshc="sshpass -p $password ssh -t ${username}@${address} " 
else
	sshc=""
#echo $sshc
fi

output="$(date +"%d-%T")"	

if [ "$cpuUsage" = "1" ]; then
#	message=`$sshc "top -n 2|grep Cpu|tail -n1"`
#	echo $message
	comm="top -n 2 -d1 -b"
	message=$($sshc $comm 2>&1|grep Cpu|tail -n1)
	v0=$(echo $message|awk '{print $2+$4+$6+$10+$12+$14+$16}')
	output="${output}, $v0"
fi

if [ "$program" != "" ]; then
	comm="top -b -n 1"
	message=$($sshc $comm 2>&1|grep -E "%CPU|$program")			# -b is important, without it top output escaped sequence, thus could find the exact index
#	echo "$message"
#	index=$(getIndexOfWord "%CPU" $(echo "$message"|head -n 1))
	message1=$(echo "$message"|grep %CPU|tr -dc "[:print:]\n")		# seems that reading from ssh would include some special chars that we need to get rid of
	message2=$(echo "$message"|grep $program|tr -dc "[:print:]\n")	# use tr -dc to remove special chars
#	echo "$message1"
#	echo "$message2"
	index=$(wordindex "${message1}" "%CPU")
#	echo "index=${index}"
	index0=$(wordindex "${message1}" "COMMAND")
#	if [ "$index0" != "" ]; then      #with new wordindex function, no need to minus 1
#		((--index0))
#	else
#		index0=1
#	fi
#	getIndexOfWord "%CPU" "${message1}"
#	echo "index0 = ${index0}"
#	if [ "$index" != "" ]; then			#with new wordindex function, no need to minus 1
#		((--index))
#	else
#		index=0
#	fi
	v0=""
	while IFS= read -r line; do
#    	echo "... $line ..."
		arr=($line)
		if [ "${arr[index0]}" == "$program" ]; then
			if [ "$v0" = "" ]; then
				v0="${arr[index]}"
			else
				v0="${v0}+${arr[index]}"
			fi
#			echo "${arr[index0]}"
#			echo "v0 = $v0"
		fi 
#			if [ "$index0" != "" ]; then
	done <<< "$message2"
#		v0="${message2:$index:5}"
#	else
#		v0=""
#	fi
	output="${output}, $v0"
fi

comm=
if [ "$cpuUsage" = "1" ]; then
	comm="cat /sys/class/hwmon/hwmon0/temp1_input"
fi
if [ "$humidity" = "1" ]; then
	if [ "$comm" != "" ]; then 
		comm="${comm};"
	fi
	comm="${comm}cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0040/iio\:device*/in_humidityrelative_raw;cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0040/iio\:device*/in_temp_raw"
fi
if [ "$temperature" = "1" ]; then
	if [ "$comm" != "" ]; then 
		comm="${comm};"
	fi
	comm="${comm}cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0048/hwmon/hwmon*/temp1_input"
fi
if [ "$light" = "1" ]; then
	if [ "$comm" != "" ]; then 
		comm="${comm};"
	fi
	comm="${comm}cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0044/iio\:device*/in_illuminance0_input;cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0044/iio\:device*/in_intensity_ir_raw"
fi

if [ "$i2caddr" != "" ]; then
	for addr in ${i2caddr}; do
		if [ "$comm" != "" ]; then 
			comm="${comm};" 
		fi
		comm="${comm} cat /sys/class/i2c-dev/i2c-${i2cbus}/device/${i2cbus}-00${addr}/hwmon/hwmon*/in1_input; cat /sys/class/i2c-dev/i2c-${i2cbus}/device/${i2cbus}-00${addr}/hwmon/hwmon*/curr1_input"
	done
fi

#if [ "$i2caddr" != "" ]; then
if [ "$comm" != "" ]; then
#	echo $comm
	message=$($sshc $comm 2>&1|grep -vE "Warning|Connection"|tr ',' ';'|tr '\r\n' ', '|sed 's/, $//')  
# convert ',' so each data occupy 1 position in CSV output. replace newline with comma, and remove the last one
#	echo $message
#	echo

	output="${output}, $message"
fi

echo $output
