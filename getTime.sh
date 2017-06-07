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
		adb shell echo \$EPOCHREALTIME
	else
		adb -s "$1" shell echo \$EPOCHREALTIME
fi
# adb shell date +'%s.%N'
date +'%s.%N'
