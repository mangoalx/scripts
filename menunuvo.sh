#!/bin/bash

#===========================================================================
# by John Xu
# For nuvo command
# Version 0.1
#	- basic menu
#	- associative array for parameters edit
#	- <a> for all parameters edit
#	- display current value and <Enter> to keep current value
#	- <Enter> to accept and apply
#	* regr for validating each data (re for each variable)
#	* cmdStr accept string array, so send command in series
#	* command for stop env service, watchdog
#	* warning about heater may causing damage
#	* commandline option for debug (echo instead of exec command)
#============================================================================
TAG="${0##*/}"
Version="0.1"
######################## variables #######################
declare -A thermalVars
thermalVars=(["Ch_no"]="00")
declare -A en_tableVars
en_tableVars=(["Enabled"]="00")
declare -A tecVars
tecVars=(["amtEnabled"]="00" ["tecdblEnabled"]="00")
declare -A rFanVars
rFanVars=(["Groupno"]="01" ["Chno"]="00")
declare -A sFanVars
sFanVars=(["Groupno"]="5A" ["Chno"]="40" ["Duty"]="FA")

readAllFansCmd=(
	"AA 11 01 00 00 00 00"
	"AA 11 01 01 00 00 00"
	"AA 11 01 02 00 00 00"
	"AA 11 01 03 00 00 00"
	"AA 11 01 04 00 00 00"
	"AA 11 01 05 00 00 00"
	"AA 11 02 00 00 00 00"
	"AA 11 02 01 00 00 00"
)





# for delayJitter
declare -A delayVars
delayVars=(["Delay(ms)"]=100 ["Jitter(ms)"]=500 ["Correlation(%)"]=25)
######################## functions #######################
version()
{
	echo "$TAG version $Version"
}
usage()
{
	version
	cat << EOF
	Usage: $TAG

EOF
}

#re='^[0-9]+$'
re='^[0-9A-Fa-f]{2}$'			# hex 2 digits data only
editParas()
{
	declare -n vars=$1
	
	while true	
	do
		echo "Current setting:"
		for key in ${!vars[@]}; do
			echo -n "${key}: ${vars[$key]}    "
		done
		echo

		read -n 1 -p 'Input the 1st letter of the parameter you want to edit, "a" for all, <Enter> to accept & apply: ' input
		echo
		if [[ -z "$input" ]]; then
			break
		else
			shopt -s nocasematch
#			${var1^^} to change to uppercase
			for key in ${!vars[@]}; do
				if [[ $input ==  'a'|| $input == ${key:0:1} ]]; then
					read -p "Enter new value for ${key}(${vars[$key]}): " value
					if [[ -n "$value" ]]; then
						if [[ $value =~ $re ]]; then		#if it a valid data
							vars[$key]="$value"
						else echo "Invalid data!"
						fi
					fi
					local found=1
					continue
				fi
			done
			shopt -u nocasematch
			if [[ $found != 1 ]]; then 
				echo "Invalid input!"
			fi
		fi
	done


}
delayJitter()
{
	editParas delayVars
#	tc qdisc add dev eth0 root netem delay ${dDelay}ms ${dJitter}ms ${dCorrelation}%
	tc qdisc add dev eth0 root netem delay ${delayVars["Delay(ms)"]}ms ${delayVars["Jitter(ms)"]}ms ${delayVars["Correlation(%)"]}%
	tc qdisc add dev eth1 root netem delay ${delayVars["Delay(ms)"]}ms ${delayVars["Jitter(ms)"]}ms ${delayVars["Correlation(%)"]}%
#	tc qdisc add dev eth1 root netem delay ${dVars[0]}ms ${dVars[1]}ms ${dVars[2]}%
#	tc qdisc add dev eth1 root netem delay ${dDelay}ms ${dJitter}ms ${dCorrelation}%
}
packetLoss()
{
	editParas lossVars
	tc qdisc add dev eth0 root netem loss ${lossVars["Loss(%)"]}%
	tc qdisc add dev eth1 root netem loss ${lossVars["Loss(%)"]}%
}
#################################
sendCmd()
{
	if [[ -z "$1" ]]; then
		return
	fi
#	echo $1
	sudo ./nuvoisp -a "${1}"
#	for cmd in ${!1[@]}; do
#		echo $cmd
#		sudo ./nuvoisp -a "${cmd}"
#	done
}
checkVersion()
{
	echo "Aprom version"
	cmdStr="AA 40 00 00 00 00 00"
	sendCmd "$cmdStr"

	echo "env table version"
	cmdStr="AA 37 00 02 00 00 00"
	sendCmd "$cmdStr"
}
disableEnv()
{
	editParas en_tableVars
	cmdStr="AA 36 ${en_tableVars["Enabled"]} 00 00 00 00"
	sendCmd "$cmdStr"
}
readThermals()
{
	editParas thermalVars
	cmdStr="AA 10 ${thermalVars["Ch_no"]} 01 00 00 00"
	sendCmd "$cmdStr"
}
tecCooler()
{
	readCmdStr="AA 31 00 00 00 00 00"
	sendCmd "$readCmdStr"
	editParas tecVars
	cmdStr="AA 31 01 ${tecVars['amtEnabled']} ${tecVars['tecdblEnabled']} 00 00"
	sendCmd "$cmdStr"
}
#============= menu and submenus ===================
submenuInit() {
	echo "Stop envctl service to avoid communition jam (watchdog will be stopped simultaneously). Disable env-table if you don't want system auto recover settings."
	echo "Warning! When disabled env-table, some operations like turning on heater at room temperature may damage the device."
	local PS3='Please select an item to test (Enter to re-display the menu): '
	local options=(
		"Stop envctl service & watchdog"
		"Restart envctl service"
		"Disable env-table" 
		"Enable env table"
		"eXit")
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in
			s | S) opt="Stop";;
			r | R) opt="Rest";;
			d | D) opt="Disa";;
			e | E) opt="Enab";;
			x | X) opt="eXit";;
		esac

		case $opt in
			eXit)
				return
				;;
			Stop*)				#stop envctl service
				sudo systemctl stop envctl.service
#				cmdStr="AA 01 00 00 00 00 00"
				cmdStr=""
              	;;
			Rest*)				#restart envctl service
				sudo systemctl start envctl.service
#				cmdStr="AA 01 01 00 00 00 00"
				cmdStr=""
				;;
			Disa*)				#OC heater on
				cmdStr="AA 36 01 00 00 00 00"
				;;
			Enab*)				#OC heater off
				cmdStr="AA 36 01 01 00 00 00"
				;;
			*)
				echo "Invalid option $opt"
				cmdStr=""
				;;
		esac
	sendCmd "$cmdStr"
	done
}

submenuHeater() {
	local PS3='Please select an item to test (Enter to re-display the menu): '
	local options=(
		"Read current status"
		"Ee heater on" 
		"ee heater oFf"
		"Oc heater on"
		"oC heater off"
		"eXit")
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in
			r | R) opt="Read";;
			e | E) opt="Ee";;
			f | F) opt="ee";;
			o | O) opt="Oc";;
			c | C) opt="oC";;
			x | X) opt="eXit";;
		esac

		case $opt in
			eXit)
				return
				;;
			Ee*)				#EE heater on
				cmdStr="AA 34 01 01 00 00 00"
				;;
			ee*)				#EE heater off
				cmdStr="AA 34 01 00 00 00 00"
				;;
			Oc*)				#OC heater on
				cmdStr="AA 32 01 01 00 00 00"
				;;
			oC*)				#OC heater off
				cmdStr="AA 32 01 00 00 00 00"
				;;
			Read*)
				cmdStr="AA 34 00 00 00 00 00"
				sendCmd "$cmdStr"
				cmdStr="AA 32 00 00 00 00 00"
				sendCmd "$cmdStr"
				cmdStr=""
              	;;
			*)
				echo "Invalid option $opt"
				cmdStr=""
				;;
		esac
	sendCmd "$cmdStr"
	done
}

submenuTec() {
	local PS3='Please select an item to test (Enter to re-display the menu): '
	local options=(
		"Read current status"
		"Atm tec on, dbl tec off" 
		"Dbl tec on, atm tec off"
		"Both tecs on"
		"None, both tecs off"
		"eXit")
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in
			r | R) opt="Read";;
			a | A) opt="Atm";;
			d | D) opt="Dbl";;
			b | B) opt="Both";;
			n | N) opt="None";;
			x | X) opt="eXit";;
		esac

		case $opt in
			eXit)
				return
				;;
			Atm*)				#atm tec on
				cmdStr="AA 31 01 01 00 00 00"
				;;
			Dbl*)				#dbl tec on
				cmdStr="AA 31 01 00 01 00 00"
				;;
			Both*)				#both tec on
				cmdStr="AA 31 01 01 01 00 00"
				;;
			None*)				#both tec off
				cmdStr="AA 31 01 00 00 00 00"
				;;
			Read*)
				cmdStr="AA 31 00 00 00 00 00"
              	;;
			*)
				echo "Invalid option $opt"
				cmdStr=""
				;;
		esac
	sendCmd "$cmdStr"
	done
}

submenuFan() {
	local PS3='Please select an item to test (Enter to re-display the menu): '
	local options=(
		"Read all fan status"
		"read One fan status"
		"Set fan speed"
		"eXit")
	local opt
	select opt in "${options[@]}"
	do
		case $REPLY in
			r | R) opt="Read";;
			o | O) opt="read";;
			s | S) opt="Set";;
			x | X) opt="eXit";;
		esac

		case $opt in
			eXit)
				return
				;;
			Set*)				#set fan speed
				editParas sFanVars
				cmdStr="AA 21 ${sFanVars["Groupno"]} ${sFanVars["Chno"]} ${sFanVars["Duty"]} 00 00"
				sendCmd "$cmdStr"
				;;
			read*)				#read one fan speed
				editParas rFanVars
				cmdStr="AA 11 ${rFanVars["Groupno"]} ${rFanVars["Chno"]} 00 00 00"
				sendCmd "$cmdStr"
				;;
			Read*)
				for key in "${readAllFansCmd[@]}"; do
					sendCmd "$key"
				done
              	;;
			*)
				echo "Invalid option $opt"
				;;
		esac
	done
}

main()
{
	echo "Videri Nuvoisp Tool"
	PS3='Please enter your choice (Enter to re-display the menu): '
	options=("Version check"
			 "Initialization"
			 "Thermal sensors"
			 "Amt/tec coolers"
			 "Heaters control"
			 "Fans control"
			 "eXit")
	select opt in "${options[@]}"
	do
		case $REPLY in			
			v | V) opt="Version";;
			i | I) opt="Init";;
			t | T) opt="Ther";;
			a | A) opt="Amt";;
			h | H) opt="Heater";;
			f | F) opt="Fans";;
			x | X) opt="eXit";;
		esac

		case $opt in
			Ver*)
				checkVersion
				;;
			Ini*)
				submenuInit
				;;
			Ther*)
				readThermals
				;;
			Amt*)
				submenuTec
				;;
			Heat*)
				submenuHeater
				;;
			Fan*)
				submenuFan
				;;
		    "eXit")
		        break
		        ;;
		    *) echo "invalid option $REPLY, opt is $opt";;
		esac
	done
}
####################################################################
main

