#!/bin/bash

#===========================================================================
# by John Xu
# For opci series telemetry test
# Version 0.1
#
#	* Error check (result contains digit number only means success)
#	* Check different sensors according to part model name or part no.
#	* Create table or list for dumping for each model
#	- Auto check part no - 
#	- Allow 'Q' for quit 'A' for auto etc, check $REPLAY and replace $opt before case
#	* Check if device is already created, remove new_device error
#	
#	* Mac address
#	* Efivars
#	* Backlight (on/off, brightness)
#	* Cpu_temp (cpu0, cpu1/hwmon1 5 values)
#	* Reset button
# 	* Accelerometer
#	* Gyrometer


TAG="${0##*/}"

GUID=a0999a12-8bbe-4255-ac0b-9534193407e7
EFIVAR_PATH="/sys/firmware/efi/efivars"

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

partnumber=$(GET_EFIVAR PartNumber)
#partnumber="VEN048CSVWM00"
echo "$TAG: partnumber=[$partnumber]"

declare -A canvas_partno			#dictionary for partno to canvas converting
canvas_partno=([VEN026QSNWM00]=QSMi [VEN026QSNWM50]=QSMi_R211 [VEN032FSNWM00]=3SMi [VEN048CSVWM00]=CC48SMi)

i2cbus=$(ls /sys/bus/pci/devices/0000\:00\:16.2/i2c_designware.2/ | grep i2c | cut -d "-" -f 2)
echo "$TAG: i2cbus=[$i2cbus]"

errorCount=0				#For counting errors occurred

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

CC48SMi_Sensors=("40" "41" "42" "44" "45" "46" "48" "4d" "4e" "6f")
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
)
	
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
		3SMi)	Sensors=("${TSMi_Sensors[@]}");;
		QSMi_R211) Sensors=("${QSMi_Sensors[@]}");;
		QSMi)	Sensors=("${QSMi_Sensors[@]}");;
		CC48SMi)	Sensors=("${CC48SMi_Sensors[@]}");;
		*)		echo "unknow canvas, could not test it";;
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

submenu () {
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
		"6f - mcp7941x RTC/power_cycle"
		"Scan I2C bus" 
		"Mac addresses" 
		"Efivars"
		"On - Backlight on"
		"oFF - Backlight off"
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
main()
{
	echo "Videri OPCi Telemetry Test"
	PS3='Please enter your choice (Enter to re-display the menu): '
	options=("Automatically test based on partnumber"
			 "Manually choose sensor to test"
			 "Test 3SMi"
			 "Test QSMi"
			 "Test CC48SMi"
			 "eXit")
	select opt in "${options[@]}"
	do
		case $REPLY in			#a for auto, m for manual, 3 for 3smi, q for qsmi, c for cc48smi
			a | A) opt="${options[0]}";;
			m | M) opt="${options[1]}";;
			q | Q) opt="${options[3]}";;
			c | C) opt="${options[4]}";;
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
		        submenu
		        ;;
		    *SMi)						#For 3SMi, CC48SMi, QSMi
				arr=($opt)				#put string into an array
				test_canvas "${arr[1]}"	#index the 2nd word
		        ;;
		    "eXit")
		        break
		        ;;
		    *) echo "invalid option $REPLY, opt is $opt";;
		esac
	done
}

main

