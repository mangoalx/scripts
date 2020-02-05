#!/bin/bash

#===========================================================================
# by John Xu
# For netem setting
# Version 0.1
#

TAG="${0##*/}"
Version="0.1"
######################## variables #######################
# for delayJitter
declare -A delayVars
delayVars=(["Delay(ms)"]=100 ["Jitter(ms)"]=500 ["Correlation(%)"]=25)
#dDelay=100
#dJitter=500
#dCorrelation=25
#dVars=(100 500 25)
#dVarNames=("Delay(ms)" "Jitter(ms)" "Correlation(%)")

# for packetLoss
declare -A lossVars=(["Loss(%)"]=20)

# for packetCorrupt
declare -A corrVars=(["Corrupt(%)"]=15)

# 
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

		read -n 1 -p 'Input the 1st letter of the parameter you want to change, <Enter> to skip:' input
		echo
		if [[ -z "$input" ]]; then
			break
		else
			shopt -s nocasematch
#			${var1^^} to change to uppercase
			for key in ${!vars[@]}; do
				if [[ $input == ${key:0:1} ]]; then
					read -p "Enter new value for ${key}: " value
					vars[$key]=$value
					local found=1
					continue
				fi
			done
			if [[ $found != 1 ]]; then 
				echo "Invalid input!"
			fi
		fi
	done


}
stopNetem()
{
	tc qdisc del dev eth0 root 2>null
	tc qdisc del dev eth1 root 2>null
}
showNetem()
{
	tc qdisc show dev eth0
	tc qdisc show dev eth1	
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
packetCorrupt()
{
	editParas corrVars
	tc qdisc add dev eth0 root netem corrupt ${corrVars["Corrupt(%)"]}%
	tc qdisc add dev eth1 root netem corrupt ${corrVars["Corrupt(%)"]}%
}

main()
{
	echo "Videri NETEM Test"
	PS3='Please enter your choice (Enter to re-display the menu): '
	options=("stoP netem"
			 "Show netem setting"
			 "Delay & jitter"
			 "packet Loss"
			 "packet Corruption"
			 "eXit")
	select opt in "${options[@]}"
	do
		case $REPLY in			#a for auto, m for manual, 3 for 3smi, q for qsmi, c for cc48smi, r for R211
			p | P) opt="${options[0]}";;
			s | S) opt="${options[1]}";;
			d | D) opt="${options[2]}";;
			l | L) opt="${options[3]}";;
			c | C) opt="${options[4]}";;
			x | X) opt="eXit";;
		esac
#		if [ "$REPLY" = "q" ] 
#			then opt="Quit"
#				echo "quit chosen"
#		fi
		case $opt in
			stoP*)
				stopNetem
				;;
			
			Show*)
				showNetem
				;;
		    Delay*)
				stopNetem
		        delayJitter
		        ;;
		    *Loss)
				stopNetem
				packetLoss
		        ;;
		    *Corruption)
				stopNetem
				packetCorrupt
		        ;;
		    "eXit")
		        break
		        ;;
		    *) echo "invalid option $REPLY, opt is $opt";;
		esac
	done
}

main

