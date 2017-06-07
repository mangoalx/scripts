#!/bin/bash
# Install all apks in current folder via adb
# Authur: John Xu
# Should check if $1 exists then use -s option

	for f in *.apk
	do
		if [ -z "$1" ]
			then 
				adb install -r "$f"
			else 
				adb -s "$1" install -r "$f"
		fi
	done


