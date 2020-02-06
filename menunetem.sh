#!/bin/bash

#===========================================================================
# by John Xu
# For netem setting
# Version 0.1
#	- basic menu, tc control commands
#	- associative array for parameters edit
#	* combine netem and tbf togather 
#	* download/upload control respectively
#	* <a> for all parameters edit

TAG="${0##*/}"
Version="0.1"
######################## variables #######################
# for delayJitter
declare -A delayVars
delayVars=(["Delay(ms)"]=100 ["Jitter(ms)"]=500 ["Ncorrelation(%)"]=25)
#dDelay=100
#dJitter=500
#dCorrelation=25
#dVars=(100 500 25)
#dVarNames=("Delay(ms)" "Jitter(ms)" "Correlation(%)")

# for packetLoss
declare -A lossVars=(["Loss(%)"]=20)

# for packetCorrupt
declare -A corrVars=(["Corrupt(%)"]=15)

# for downloadLimit
declare -A downVars=(["Rate(kbps)"]=1000 ["Burst"]=1600 ["Alatency"]=20000 ["Delay(ms)"]=100 ["Jitter(ms)"]=50 ["Ncorrelation(%)"]=25 ["Loss(%)"]=10 ["Corrupt(%)"]=5)

# for uploadLimit
declare -A upVars=(["Rate(kbps)"]=1000 ["Burst"]=1600 ["Alatency"]=20000 ["Delay(ms)"]=100 ["Jitter(ms)"]=50 ["Ncorrelation(%)"]=25 ["Loss(%)"]=10 ["Corrupt(%)"]=5)

# for bandVars
declare -A bandVars=(["Rate(kbps)"]=1000 ["Burst"]=1600 ["Alatency"]=20000)
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
stopDownNetem()
{
	tc qdisc del dev eth0 root 2>null
}
stopUpNetem()
{
	tc qdisc del dev eth1 root 2>null
}
stopNetem()
{
	stopDownNetem
	stopUpNetem
}
showNetem()
{
	echo -n "Downstream:";	tc qdisc show dev eth0
	echo -n "Upstream:";	tc qdisc show dev eth1	
}
bandwidth()
{
	editParas bandVars
	tc qdisc add dev eth0 root tbf rate ${bandVars["Rate(kbps)"]}kbit burst ${bandVars["Burst"]} latency ${bandVars["Alatency"]}
	tc qdisc add dev eth1 root tbf rate ${bandVars["Rate(kbps)"]}kbit burst ${bandVars["Burst"]} latency ${bandVars["Alatency"]}
}
delayJitter()
{
	editParas delayVars
#	tc qdisc add dev eth0 root netem delay ${dDelay}ms ${dJitter}ms ${dCorrelation}%
	tc qdisc add dev eth0 root netem delay ${delayVars["Delay(ms)"]}ms ${delayVars["Jitter(ms)"]}ms ${delayVars["Ncorrelation(%)"]}%
	tc qdisc add dev eth1 root netem delay ${delayVars["Delay(ms)"]}ms ${delayVars["Jitter(ms)"]}ms ${delayVars["Ncorrelation(%)"]}%
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
downloadLimit()
{
	editParas downVars
	tc qdisc add dev eth0 root handle 1: netem delay ${downVars["Delay(ms)"]}ms ${downVars["Jitter(ms)"]}ms ${downVars["Ncorrelation(%)"]}% loss ${downVars["Loss(%)"]} corrupt ${downVars["Corrupt(%)"]}
	tc qdisc add dev eth0 parent 1:1 handle 10: tbf rate ${downVars["Rate(kbps)"]}kbit burst ${downVars["Burst"]} latency ${downVars["Alatency"]}

}
uploadLimit()
{
	editParas upVars
	tc qdisc add dev eth1 root handle 1: netem delay ${upVars["Delay(ms)"]}ms ${upVars["Jitter(ms)"]}ms ${upVars["Ncorrelation(%)"]}% loss ${upVars["Loss(%)"]} corrupt ${upVars["Corrupt(%)"]}
	tc qdisc add dev eth1 parent 1:1 handle 10: tbf rate ${upVars["Rate(kbps)"]}kbit burst ${upVars["Burst"]} latency ${upVars["Alatency"]}
#	tc qdisc add dev eth1 root handle 1: tbf rate ${upVars["Rate(kbps)"]}kbit burst ${upVars["Burst"]} latency ${upVars["Alatency"]}
#	tc qdisc add dev eth1 parent 1:1 handle 10: netem delay ${upVars["Delay(ms)"]}ms ${upVars["Jitter(ms)"]}ms ${upVars["Ncorrelation(%)"]}% loss ${upVars["Loss(%)"]} corrupt ${upVars["Corrupt(%)"]}
}
main()
{
	echo "Videri NETEM Test"
	PS3='Please enter your choice (Enter to re-display the menu): '
	options=("stoP netem"
			 "Show netem setting"
			 "Bandwidth limit"
			 "Jitter & delay"
			 "packet Loss"
			 "packet Corruption"
			 "Download limit"
			 "Upload limit"
			 "eXit")
	select opt in "${options[@]}"
	do
		case $REPLY in			#a for auto, m for manual, 3 for 3smi, q for qsmi, c for cc48smi, r for R211
			p | P) opt="${options[0]}";;
			s | S) opt="${options[1]}";;
			b | B) opt="${options[2]}";;
			j | J) opt="${options[3]}";;
			l | L) opt="${options[4]}";;
			c | C) opt="${options[5]}";;
			d | D) opt="${options[6]}";;
			u | U) opt="${options[7]}";;
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
			Band*)
				stopNetem
				bandwidth
				;;
		    Jitter*)
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
		    Download*)
				stopDownNetem
				downloadLimit
		        ;;
		    Upload*)
				stopUpNetem
				uploadLimit
		        ;;
		    "eXit")
		        break
		        ;;
		    *) echo "invalid option $REPLY, opt is $opt";;
		esac
	done
}

main

