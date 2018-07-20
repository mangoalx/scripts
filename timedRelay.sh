#!/bin/bash
# 
# by John Xu
# For Numato Lab relay board timed control
# Version 0.1
#

############ Functions
version()
{
	echo "timedRelay.sh version 0.1"
}
usage()
{
	version
    echo "usage: timedrelay [[-h] | [-v] | [-n number] [-t delay] [[-d] devicePort]] [-p period]"
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-t or --time to specify toggle interval, if omitted, will be random number between 1 to 5"
	echo "-d or --device to specify the device path, default as /dev/ttyACM0"
	echo "-n or --number to specify which relay no. to toggle, default as 0"
	echo "-p or --period to specify how long to run the test, unlimited if omitted or set 0"
}
argError()
{
	echo "********Argument error."
	usage
}

relayOn()
{
	echo "Turning relay on"
	$cmdSwitchOn
#	echo $cmdSwitchOn
}
relayOff()
{
	echo "Turning relay off"
	$cmdSwitchOff
}
################################
devicePort="/dev/ttyACM0"
relayNo=0
toggleDelay=			
randomDelay=0
elapsedTime=0
period=0

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
		-t | --time)			shift
								toggleDelay=$1
								;;
		-d | --device)			shift
								devicePort=$1
								;;
		-n | --number)			shift
								relayNo=$1
								;;
		-p | --period)			shift
								period=$1
								;;
        * ) 					argError
								exit
                                
    esac
    shift
done
#python relaywrite.py /dev/ttyACM0 0 on
	cmdSwitchOn="python python/relayControl/relaywrite.py $devicePort $relayNo on"
	cmdSwitchOff="python python/relayControl/relaywrite.py $devicePort $relayNo off"

if [ -z "$toggleDelay" ]
then 
	randomDelay=1
fi

STARTTIME=$(date +%s)

while true;
do
	if [ "$randomDelay" = "1" ]
	then
		toggleDelay=$(( ( RANDOM % 5 )  + 1 ))
	fi

	relayOn
	sleep $toggleDelay
	relayOff
	sleep $toggleDelay
	ENDTIME=$(date +%s)
	elapsedTime=$(($ENDTIME - $STARTTIME))
	echo "Test elapsed time: $elapsedTime S"
	echo "toggle delay: $toggleDelay"
	if [ $period != 0 ]
	then
		if (( elapsedTime > period ))
		then
			break
		fi
	fi
done

