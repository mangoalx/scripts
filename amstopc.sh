#!/bin/bash
# am force-stop a package
# Authur: John Xu
# if $1 exists, it is the package name
	adbc="adb"
	echo "adbc is like this $adbc"
	if [ -z "$1" ]							#if there is not an argument, exit
		then echo "I quit" 
		exit
set -x
	else "$adbc" shell am force-stop "$1"
set +x
	fi
#	amstopc="$adbc shell am force-stop"
#	export adbc
#	$adbc shell top -n 1|grep com.videri|xargs -n 1 amstopc.sh

