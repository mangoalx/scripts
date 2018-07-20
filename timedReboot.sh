#!/bin/bash
# 
# by John Xu
# For timely control Whim screen software reboot
# Version 0.1
#

############ Functions
version()
{
	echo "timedReboot.sh version 0.1"
}
usage()
{
	version
    echo "usage: timedreboot [[-h] | [-v] | [-t delay] serial1 serial2 ... ]"
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-t or --time to specify reboot interval, if omitted, will be 200 seconds"
	echo "-c or --command to specify command to be sent, if omitted, will be reboot, i.e. adb shell reboot"
	echo "-p or --period to specify how long to run the test, unlimited if omitted or set 0"
	echo "-n or --connect to connect the device before sending command, i.e. send adb connect serialNo first. The serial number must be listed at the end"
	echo "list all devices serial numbers that you want to reboot. If there is only 1 adb device present, it can be omitted"
}
argError()
{
	echo "********Argument error."
	usage
}

rebootOn()
{
set -x
	echo "Sending command"
	if [ -z "$serial" ]
	then
		adb shell reboot
	else
		while [ "$1" != "" ]; do
			if [ $connect != 0 ]
			then 
				adb connect $1
			fi
			adb -s $1 shell $sCommand
		    shift
		done
	fi
set +x	
#	echo $cmdSwitchOn
}
################################
rebootDelay=200
elapsedTime=0
period=0
connect=0
sCommand="reboot"
serial=

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
		-t | --time)			shift
								rebootDelay=$1
								;;
		-n | --connect)			
								connect=1
								;;
		-c | --command)			shift
								sCommand=$1
								;;
		-p | --period)			shift
								period=$1

								;;
        * ) 					serial=$1
								break
                                
    esac
    shift
done

STARTTIME=$(date +%s)
#put the rest args in an array to pass to rebootOn function
args=$@

while true;
do
	rebootOn $args
	sleep $rebootDelay
	ENDTIME=$(date +%s)
	elapsedTime=$(($ENDTIME - $STARTTIME))
	echo "Test elapsed time: $elapsedTime S"
	echo "reboot delay: $rebootDelay"
	if [ $period != 0 ]
	then
		if (( elapsedTime > period ))
		then
			break
		fi
	fi
done

