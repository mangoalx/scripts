#!/bin/bash
# Script adb+
# Usage
# You can run any command adb provides on all your currently connected devices
# ./adb+ <command> is the equivalent of ./adb -s <serial number> <command>
#
# Examples 
# ./adb+ version
# ./adb+ install apidemo.apk
# ./adb+ uninstall com.example.android.apis
#
# 
# Should check if $1 exists then use -s option
#adb -s "$1" shell echo \$EPOCHREALTIME
if [ -z "$1" ]
	then
		T1=$(adb shell echo \$EPOCHREALTIME | tr -d '\r')
	else
		T1=$(adb -s "$1" shell echo \$EPOCHREALTIME | tr -d '\r')
fi
# adb shell date +'%s.%N'
T2=$(date +'%s.%N')
echo $T1, $T2
