#!/bin/bash
# whimset, stop whim watchdog, start settings, then run adbkeyin, finally restart whim watchdog
# Authur: John Xu
# V0.1
clear
echo "This script is used to start android setting on Whim"
echo "Useage: whimset [serialNo]"

if [ -z "$1" ]
	then
		ADB="adb"
	else
		ADB="adb -s $1"
fi

#stop whim watchdog
$ADB shell am force-stop com.videri.canvas.watchdog
$ADB shell am start com.android.settings
adbkeyin $1
$ADB shell am start com.videri.canvas.watchdog

