#!/bin/bash

#===========================================================================
# by John Xu
# For opci remote test
#	When testing opci hw remotely over ssh connection, need a tool bash
#	to be installed, so we can call it to perform necessary operation
# Version 0.1
#	1st version, bash script to be called via ssh, take commandline paras
#	+ read partno, serial no., firmware version, resolution
#	+ auto hw test, add reset, Accelerometer, Gyrometer

Version="V0.1"

TAG="${0##*/}"

GUID=a0999a12-8bbe-4255-ac0b-9534193407e7
EFIVAR_PATH="/sys/firmware/efi/efivars"
FIRMWARE_VERSION_FILE="/etc/version"

NA="N/A"

version()
{
	echo "$TAG version $Version"
}
usage()
{
	version
	cat << EOF
<<<<<<< HEAD
	USAGE: $TAG [-h|-v|-r|-t] [parameter]
		Without any option/parameter, to enter interactive menu
		-v or --version to display version information
		-h or --help to display help information
		-r or --read to read a sensor or variable, use parameter to specify
			parameter for read could be 1 of:
				Pn - part number
				Sn - serial number
				Fw - firmware version
				Dim- dimension/resolution
				Efi- Efi variables
				Mac- Mac addresses
				Cpu- cpu temeratures
				Acc- accelerator sensor
				Gy - gyrometer sensor
				Re - reset butoon
				I2C address of sensors [40,41,42,44,45,46,48,4d,4e,4f,6f]
		-t or --test to test the device, use parameter to specify device type
			parameter for test could be 1 of:
				auto - read device part number to find out device type
				device model [8U2i,3smi,R211,Qsmi,Cc48smi]
=======
	USAGE: $TAG [-hvfcxpe] [-d <delay>] [[-s] <serialNo>]
		Without parameter, will start interactive menu mode
		-v or --version to display version information
		-h or --help to display help information

>>>>>>> 439ac308c6bb7eb191d907147b0f644440862499
EOF
}

GET_EFIVAR()
{
    NAME=$1
    RET=""
    if [ $# -eq 1 ]; then
        if [ -f "${EFIVAR_PATH}/${NAME}-${GUID}" ]; then
            RET=$(tr -d '\0\a' < "${EFIVAR_PATH}/${NAME}-${GUID}")
        fi
    fi
    echo "${RET}"
}

GET_ALLEFIVARS()
{
	for f in ${EFIVAR_PATH}/*${GUID}
		do echo $f;cat  $f;echo;done
}
partnumber=$(GET_EFIVAR PartNumber)		# need partnumber for auto hw test
GET_PARTNO()
{
#	partnumber=$(GET_EFIVAR PartNumber)
	echo "partnumber=[$partnumber]"
	echo "${canvas_partno[$partnumber]}"
}

GET_SERIALNO()
{
	serialno=$(GET_EFIVAR SerialNumber)
	echo "serialno=[$serialno]"
}

GET_FIRMWAREVERSION()
{
	fwver=$(cat $FIRMWARE_VERSION_FILE)
	echo "fwversion=[$fwver]"
}

declare -A canvas_partno			#dictionary for partno to canvas converting
canvas_partno=([VEN026QSNWM00]=Qsmi [VEN026QSNWM50]=qsmi_R211 [VEN032FSNWM00]=3smi [VEN048CSVWM00]=Cc48smi [VEN075ULPWB10]=8U2i [VEN075ULPWB20]=8U2i)

i2cbus=$(ls /sys/bus/pci/devices/0000\:00\:16.2/i2c_designware.2/ | grep i2c | cut -d "-" -f 2)

GET_I2CBUS()
{
	echo "i2cbus=[$i2cbus]"
}

errorCount=0				#For counting errors occurred

originOrientation=""
execDisplay() {
#	MESSAGE="${1}"
	eval ${1}
}
error_nocheck() {
#	MESSAGE="${1}"
	MESSAGE="$(eval ${1} 2>&1)"
}
error_check() {
#	MESSAGE="${1}"
	MESSAGE="$(eval ${1} 2>&1)"
    if [ $? -ne 0 ]; then
        echo "${TAG}: Command: ${1} Error: ${MESSAGE}"
		let "errorCount++"
#		echo "errorCount = $errorCount"
    else
        echo $MESSAGE
    fi
}
#number could not be used as 1st letter of a name, so use E instead of 8 for 8u2i
EU2i_Sensors=("40" "41" "44" "45" "46" "4f" "6f" "Re" "Ac" "Gy")
CC48SMi_Sensors=("40" "41" "42" "44" "45" "46" "48" "4d" "4e" "6f" "Re" "Ac" "Gy")
TSMi_Sensors=(				#number could not be used as 1st letter of a name, so use T instead of 3
	"40"
	"41"
	"42"
	"44"
	"45"
	"46"
	"48"
	"4d"
	"6f"
	"Re"
	"Ac"
	"Gy"
)
QSMi_Sensors=(
	"40"
	"41"
	"42"
	"44"
	"45"
	"46"
	"48"
	"4d"
	"6f"
	"Re"
	"Ac"
	"Gy"
)
QSMi_R211_Sensors=(
	"40"
	"41"
	"45"
	"46"
	"48"
	"4d"
	"6f"
	"Re"
	"Ac"
	"Gy"
)	#removed 42 & 44, from QSMi_Sensors
	
scani2c() 			#Scan the I2C bus for available devices
{
	i2cdetect -r -y ${i2cbus}
}
test_device()		#To test a device, create it first if not done, then dump sensor
{
	create_device "$1"
	dump_sensor "$1"
}
test_canvas()		#Test a canvas, find sensors and check each of them
{
	local Sensors=()
	local sensor=""
	case $1 in
		8U2i)	Sensors=("${EU2i_Sensors[@]}");;
		3smi)	Sensors=("${TSMi_Sensors[@]}");;
		R211)	;&
		qsmi_R211) Sensors=("${QSMi_R211_Sensors[@]}");;
		Qsmi)	Sensors=("${QSMi_Sensors[@]}");;
		Cc48smi)	Sensors=("${CC48SMi_Sensors[@]}");;
		*)		echo "unknow canvas $1, could not test it"
				return;;
	esac
	echo "testing $1"
	errorCount=0
	for sensor in "${Sensors[@]}"
	do
		echo "$sensor"
		test_device "$sensor"
	done
	echo "Total error: $errorCount"
}
create_device()		#create a device, $1 as I2C address, thus defined the device type
{
#    echo "$TAG: create i2c and gpio devices."
	case $1 in
		40)		error_nocheck "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        41)		error_nocheck "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        42)		error_nocheck "echo ina220 0x42 > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        44)		error_nocheck "echo isl29023 0x44 > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        45)		error_nocheck "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        46)		error_nocheck "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        48)		error_nocheck "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        4d)		error_nocheck "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        4e)		error_nocheck "echo ina220 0x4e > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        4f)		error_nocheck "echo ina220 0x4f > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
        6f)		error_nocheck "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$i2cbus/device/new_device";;
		Re)		error_nocheck "echo 438 > /sys/class/gpio/export";;
		* )		#echo "unknow device, could not create device"
	esac
}
dump_sensor()		#dump a sensor data, $1 as I2C address
{
#    echo "$TAG: create i2c and gpio devices."
	case $1 in
		40)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0040/iio\:device*/in_humidityrelative_raw"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0040/iio\:device*/in_temp_raw"
				;;
        41)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0041/hwmon/hwmon*/in0_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0041/hwmon/hwmon*/in1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0041/hwmon/hwmon*/curr1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0041/hwmon/hwmon*/power1_input"
				;;
        42)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0042/hwmon/hwmon*/in0_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0042/hwmon/hwmon*/in1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0042/hwmon/hwmon*/curr1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0042/hwmon/hwmon*/power1_input"
				;;
        45)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0045/hwmon/hwmon*/in0_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0045/hwmon/hwmon*/in1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0045/hwmon/hwmon*/curr1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0045/hwmon/hwmon*/power1_input"
				;;
        46)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0046/hwmon/hwmon*/in0_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0046/hwmon/hwmon*/in1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0046/hwmon/hwmon*/curr1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0046/hwmon/hwmon*/power1_input"
				;;
        4d)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004d/hwmon/hwmon*/in0_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004d/hwmon/hwmon*/in1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004d/hwmon/hwmon*/curr1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004d/hwmon/hwmon*/power1_input"
				;;
        4e)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004e/hwmon/hwmon*/in0_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004e/hwmon/hwmon*/in1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004e/hwmon/hwmon*/curr1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004e/hwmon/hwmon*/power1_input"
				;;
        4f)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004f/hwmon/hwmon*/in0_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004f/hwmon/hwmon*/in1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004f/hwmon/hwmon*/curr1_input"
        		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-004f/hwmon/hwmon*/power1_input"
				;;
        44)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0044/iio\:device*/in_illuminance0_input"
				error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0044/iio\:device*/in_intensity_ir_raw"
				;;
        48)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-0048/hwmon/hwmon*/temp1_input";;
        6f)		error_check "cat /sys/class/i2c-dev/i2c-$i2cbus/device/$i2cbus-006f/rtc/rtc*/time";;

		Sc)
			scani2c
			;;
		Ma)
			error_check "cat /sys/class/net/eth0/address"
			error_check "cat /sys/class/net/wlan0/address"
			error_check "hcitool dev"
			;;
		Ef)
			GET_ALLEFIVARS;;
		On)
			error_check "echo 0 > /sys/class/backlight/intel_backlight/bl_power"
			;;
		oF)
			error_check "echo 1 > /sys/class/backlight/intel_backlight/bl_power"
			;;
		Cp)
			error_check "cat /sys/class/hwmon/hwmon1/temp?_input"
			;;
		Re)
			error_check "cat /sys/class/gpio/gpio438/value"
			;;
		Ac)
			error_check "cat /sys/bus/iio/devices/iio\:device0/*raw"
			;;
		Gy)
			error_check "cat /sys/bus/iio/devices/iio\:device1/*raw"
			;;

		* )		echo "unknow device, could not dump sensor"
	esac
}
generate_post_data ()
{
  cat <<EOF
{
  "orientation": "$1"
}
EOF
}
generate_patch_data ()
#  "power": "$1","brightness": "$2"
{
  cat <<EOF
{
  "$1": "$2"
}
EOF
}
test_Orientation () {
	local input
	originOrientation=$(curl http://127.0.0.1:5000/sysinfo/orientation 2>/dev/null | jq '.orientation' | tr -d \")
	echo "originOrientation= $originOrientation"
	while true	
	do
		read -p 'Input the 1st letter of the orientation to be set (Normal/Inverted/Left/Right/Original), x to exit:' input
		case $input in
			n* | N*) input="normal" ;;
			i* | I*) input="inverted" ;;
			l* | L*) input="left" ;;
			r* | R*) input="right" ;;
			o* | O*) input="$originOrientation" ;;
			x* | X*) return ;;
			*) echo "Invalid input"
				continue
		esac
		echo $input
		curl -i -H "Content-Type: application/json" -X POST -d "$(generate_post_data $input)" http://127.0.0.1:5000/sysinfo/orientation
	done	
}
test_Sensors () {
	local sensors=$(curl http://127.0.0.1:5000/environment/sensors 2>/dev/null | jq '."Environment sensor list"[]' | tr -d \")
	for s in $sensors
	do
		echo "${s}:"
		curl http://127.0.0.1:5000/environment/sensors/$s
	done
}
test_Power () {
	local sensors=$(curl http://127.0.0.1:5000/power 2>/dev/null | jq '."Power sensor list"[]' | tr -d \")
	for s in $sensors
	do
		echo "${s}:"
		curl http://127.0.0.1:5000/power/$s
	done
}
test_Display () {
	local displays=$(curl http://127.0.0.1:5000/display 2>/dev/null | jq '."Display list"[]' | tr -d \")
	for d in $displays
	do
		echo "${d}:"
		curl http://127.0.0.1:5000/display/$d
	done
}
test_Backlight () {
	local brightness power
	curl http://127.0.0.1:5000/display/backlight
	while true
	do
		read -p 'Input brightness [0 ~ 100, a for auto, P/p for on/off, H/h for hunt_effect on/off, x to exit, Enter to read]:' brightness
		if [ -z $brightness ]
			then 	curl http://127.0.0.1:5000/display/backlight
			continue
		fi
		case $brightness in
			P) data="on"
			   name="power" ;;
			p) data="off"
			   name="power" ;;
			H) data="on"
			   name="hunt_effect" ;;
			h) data="off"
			   name="hunt_effect" ;;
			a* | A*) data="auto"
				name="brightness" ;; 
			x* | X*) return ;;
			*) data="$brightness"
			   name="brightness" ;;
		esac
#		curl -i -H "Content-Type: application/json" -X PATCH -d '{"power":"on", "brightness": 25}' http://127.0.0.1:5000/display/backlight
# curl -i -H "Content-Type: application/json" -X PATCH -d '{"brightness": "auto"}' http://127.0.0.1:5000/display/backlight
#		echo $(generate_patch_data $brightness $power)
		curl -i -H "Content-Type: application/json" -X PATCH -d "$(generate_patch_data $name $data)" http://127.0.0.1:5000/display/backlight
	done
}
test_Resetbutton () {
	local answer
	echo "Testing reset button ... press Enter to quit!"
	while true
	do
		read -t 1 -n 1 answer
		if [ $? == 0 ]; then		#timeout without user input
			if [ -z $answer ]
				then break
			fi
			continue				#if user input something, skip the reading
		else						#timeout without input, then test reset button
			echo -n $(curl http://127.0.0.1:5000/sysinfo/resetbutton 2>/dev/null | jq '."Reset Button"' | tr -d \n\")
		fi
	done
}
submenuM () {
	local PS3='Please select a sensor to test (Enter to re-display the menu): '
	local options=(
		"40 - hdc1080 temp/humi" 
		"41 - ina220 Tcon 12V/10V" 
		"42 - ina220 VBB 12V/10V" 
		"44 - isl29023 ALS" 
		"45 - ina220 Vin 24V" 
		"46 - ina220 DPC 5V" 
		"48 - tmp275 Internal temp" 
		"4d - ina220 Backlight L 24V" 
		"4e - ina220 Backlight R 24V" 
		"4f - ina220 Prt-24V" 
		"6f - mcp7941x RTC/power_cycle"
		"Scan i2c bus" 
		"Mac addresses" 
		"Efivars"
		"On - backlight on"
		"oFF - backlight off"
		"Cpu_temp"
		"Reset button"
		"Accelerometer"
		"Gyrometer"
		"eXit")
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in
			#s for scan, x for exit, m for mac, e for efi
			#o for bl on, f for bl off, c for cpu temp
			#r for reset button, a for accelerometer, g for gyrometer
			s | S) opt="Scan";;
			m | M) opt="Mac";;
			e | F) opt="Efivars";;
			o | O) opt="On";;
			f | F) opt="oFF";;
			c | C) opt="Cpu_temp";;
			r | R) opt="Reset";;
			a | A) opt="Accelerometer";;
			g | G) opt="Gyrometer";;

			x | X) opt="eXit";;
		esac
#		if [ "$REPLY" = "q" ] 
#			then opt="Quit"
#				echo "quit chosen"
#		fi
		case $opt in
          eXit)
              return
              ;;
#          4* | 6f*)
#              	echo "you chose $opt"
		  *)
				addr=${opt:0:2}
				test_device "$addr"
              	;;
#          Scan*)
#              scani2c
#              ;;

#          *) echo "invalid option $REPLY";;
		esac
	done
}
submenuF () {
	local PS3='Please select an item to test (Enter to re-display the menu): '
	local options=(
		"firmware Version" 
		"Resolution dimension"
		"sysInfo"
		"Display"
		"Backlight"
		"Sensors"
		"Power"
		"Ecb_8u2i"
		"eXit")
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in
			#s for scan, x for exit, m for mac, e for efi
			#o for bl on, f for bl off, c for cpu temp
			#r for reset button, a for accelerometer, g for gyrometer
			v | V) opt="firmware Version";;
			r | R) opt="Resolution dimension";;
			i | I) opt="sysInfo";;
			d | D) opt="Display";;
			b | B) opt="Backlight";;
			s | S) opt="Sensors";;
			p | P) opt="Power";;
			e | E) opt="Ecb_8u2i";;
			x | X) opt="eXit";;
		esac

		case $opt in
			eXit)
				return
				;;
			fi*)				#firmware Version
				cat /etc/version
				;;
			Re*)				#Resolution dimension
				DISPLAY=:0 xdpyinfo|grep dim
				;;
			sy*)				#sysInfo
				execDisplay "curl http://127.0.0.1:5000/sysinfo"
				submenuSysinfo
				;;
			Di*)				#Display
				execDisplay "curl http://127.0.0.1:5000/display"
				test_Display
				;;
			Ba*)				#Backlight 
				test_Backlight ;;
			Se*)				#Sensors
				execDisplay "curl http://127.0.0.1:5000/environment/sensors"
				test_Sensors
				;;
			Po*)				#Power
				execDisplay "curl http://127.0.0.1:5000/power"
				test_Power
				;;
			Ec*)				#Ecb_8u2i
				execDisplay "curl http://127.0.0.1:5000/ecb"
				submenuEcb
				;;
			*)
				echo "Invalid option $opt"
              	;;
		esac
	done
}
submenuSysinfo () {
	local PS3='Please select an item to test (Enter to re-display the menu): '
	local options=(
		"forceUpdate" 
		"Biosversion" 
		"Model"
		"selfTest"
		"Status"
		"Resetbutton"
		"sN"
		"Apps"
		"Orientation"
		"Powercycle(reboot)"
		"eXit")
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in
			u | U) opt="forceUpdate";;
			b | B) opt="Biosversion";;
			m | M) opt="Model";;
			t | T) opt="selfTest";;
			s | S) opt="Status";;
			r | R) opt="Resetbutton";;
			n | N) opt="sN";;
			a | A) opt="Apps";;
			p | P) opt="Powercycle";;
			o | O) opt="Orientation";;
			x | X) opt="eXit";;
		esac

		case $opt in
			eXit)
				return
				;;
			fo*)				#forceUpdate
				echo "Executing force update, please wait ... "
				curl -i -H "Content-Type: application/json" -X POST -d '{"update": true}' http://127.0.0.1:5000/sysinfo/forceupdate
				;;
			Bi*)				#Model
				curl http://127.0.0.1:5000/sysinfo/BIOSversion
				;;
			Mo*)				#Model
				curl http://127.0.0.1:5000/sysinfo/model
				;;
			se*)				#selfTest
				curl http://127.0.0.1:5000/sysinfo/selftest				
				;;
			St*)				#Status
				curl http://127.0.0.1:5000/sysinfo/status
				;;
			Re*)				#Resetbutton
#				curl http://127.0.0.1:5000/sysinfo/resetbutton
				test_Resetbutton ;;
			sN*)				#SN
				curl http://127.0.0.1:5000/sysinfo/SN
				;;
			Ap*)				#Apps
				curl http://127.0.0.1:5000/sysinfo/apps
				;;
			Po*)				#Powercycle
				curl -i -H "Content-Type: application/json" -X POST -d '{"reboot": true}' http://127.0.0.1:5000/sysinfo/powercycle
				;;
			Or*)				#Orientation
				curl http://127.0.0.1:5000/sysinfo/orientation
				test_Orientation
				;;
			*)
				echo "Invalid option $opt"
              	;;
		esac
	done
}
submenuEcb () {
	local PS3='Please select an item to test (Enter to re-display the menu): '
	local options=(
		"Ecb_table" 
		"Update"
		"Door_alert"
		"Psu_error"
		"Assembly"
		"Fan_alert"
		"State"
		"Temperature_alert"
		"eXit")
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in
			e | E) opt="Ecb_table";;
			u | U) opt="Update";;
			d | D) opt="Door_alert";;
			p | P) opt="Psu_error";;
			a | A) opt="Assembly";;
			f | F) opt="Fan_alert";;
			s | S) opt="State";;
			t | T) opt="Temperature_alert";;
			x | X) opt="eXit";;
		esac

		case $opt in
			eXit)
				return
				;;
			Ec*)				#Ecb_table
				curl http://127.0.0.1:5000/ecb/ecb_table | hexdump -C
				;;
			Up*)				#Update
				curl http://127.0.0.1:5000/ecb/update
				;;
			Do*)				#Door_alert
				curl http://127.0.0.1:5000/ecb/door_alert				
				;;
			Ps*)				#Psu_error, since RC131 this item replaced door_alert
				curl http://127.0.0.1:5000/ecb/psu_error				
				;;
			As*)				#Assembly
				curl http://127.0.0.1:5000/ecb/assembly
				;;
			Fa*)				#Fan_alert
				curl http://127.0.0.1:5000/ecb/fan_alert
				;;
			St*)				#State
				curl http://127.0.0.1:5000/ecb/state
				;;
			Te*)				#Temperature_alert
				curl http://127.0.0.1:5000/ecb/temperature_alert
				;;
			*)
				echo "Invalid option $opt"
              	;;
		esac
	done
}
submenuH()
{
	echo "Videri OPCi Hardware Test"
	local PS3='Please enter your choice (Enter to re-display the menu): '
	local options=("Automatically test based on partnumber"
			 "Manually choose sensor to test"
			 "test 3smi"
			 "test Qsmi"
			 "test Cc48smi"
			 "test qsmi_R211"
			 "eXit"
			 "test 8U2i"
			)
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in			#a for auto, m for manual, 3 for 3smi, q for qsmi, c for cc48smi, r for R211
			a | A) opt="${options[0]}";;
			m | M) opt="${options[1]}";;
			q | Q) opt="${options[3]}";;
			c | C) opt="${options[4]}";;
			r | R) opt="${options[5]}";;
			u | U) opt="${options[6]}";;
			x | X) opt="eXit";;
		esac
#		if [ "$REPLY" = "q" ] 
#			then opt="Quit"
#				echo "quit chosen"
#		fi
		case $opt in
			"Automatically test based on partnumber")
				test_canvas "${canvas_partno[$partnumber]}"
				;;
		    "Manually choose sensor to test")
		        submenuM
		        ;;
		    *smi* | *8U*)				#For 3SMi, CC48SMi, QSMi, QSMi_R211, 8U2i
				arr=($opt)				#put string into an array
				test_canvas "${arr[1]}"	#index the 2nd word
		        ;;
		    "eXit")
		        return
		        ;;
		    *) echo "invalid option $REPLY, opt is $opt";;
		esac
	done
}
main()
{
	if [ $# -eq 0 ]; then
		version
		GET_I2CBUS
		GET_PARTNO
		PS3='Please enter your choice (Enter to re-display the menu): '
		options=("test Hardware"
				 "test Firmware/val"
				 "Power cycle"
				 "eXit")
		select opt in "${options[@]}"
		do
			case $REPLY in			
				h | H) opt="${options[0]}";;
				f | F) opt="${options[1]}";;
				p | P) opt="Power cycle";;
				x | X) opt="eXit";;
			esac

			case $opt in
				"test Hardware")
				    submenuH
				    ;;
				"test Firmware/val")
				    submenuF
				    ;;
				"Power cycle")
				    sudo reboot power_cycle
				    ;;
				"eXit")
				    break
				    ;;
				*) echo "invalid option $REPLY, opt is $opt";;
			esac
		done
	else	# with parameter, then direct exec command, no menu
		case $1 in
		    -h | --help )           usage
		                            ;;
		    -v | --version )        version
		                            ;;
		    -r | --read )        	
				case $2 in
					Pn*)	GET_PARTNO
							;;
					Sn*)	GET_SERIALNO
							;;
					Fw*)	GET_FIRMWAREVERSION
							;;
					Dim*)	DISPLAY=:0 xdpyinfo|grep dim ;;
					Ef*)	;& #GET_ALLEFIVARS ;;
					40*)	;&
					41*)	;&
					42*)	;&
					44*)	;&
					45*)	;&
					46*)	;&
					48*)	;&
					4d*)	;&
					4e*)	;&
					4f*)	;&
					6f*)	;&
					Mac*)	;&
					Acc*)	;&
					Gy*)	;&
					Cpu*)	;&
					Re*)	addr=${2:0:2}
							test_device "$addr"
              				;;
					
					*)	echo "Invalid parameter"
				esac
		                            ;;
		    -t | --test )
				case $2 in
					au*)	test_canvas "${canvas_partno[$partnumber]}"
		                    ;;
					8U2i)	;&
					3smi)	;&
					R211)	;&
					Qsmi)	;&
					Cc48smi)	test_canvas "$2" ;;
					*)	echo "Invalid parameter"
				esac
									;;
			*)						echo "Invalid parameter"
		esac	
	fi
}

main $*		# transfer parameters to main()

