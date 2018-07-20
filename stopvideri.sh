#!/bin/bash
# Keep checking and killing videri packages, for running cts test on VLE and Whim, stopped videri apks after each reboot
# Authur: John Xu
# Should check if $1 exists then use -s option
clear
echo "This script is used for checking and stopping videri apks"
echo "Useage: stopvideri [serialNo]"
echo 
	if [ -z "$1" ]							#if there is an argument, use it as serial number for adb command
		then adbc="adb"
	else adbc="adb -s $1"
	fi

#	export variable for amstopc to use it
	export adbc

while :
do
	$adbc "wait-for-device"
	packages=`$adbc shell top -n 1|grep -oE 'com.videri.adsync|com.videri.icanvasplayer|com.videri.superuserservice'`
#	echo $packages

	if [[ ! -z "$packages" ]]
		then
		echo "killing ... "
		echo $packages|xargs -n 1 amstopc.sh
	fi
	sleep 10			#wait for 10 seconds
done
# |cut -d ' ' -f22 
