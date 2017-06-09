#!/bin/bash
# V0.2 tesseract ocr all jpg files in parallel
# Authur: John Xu
# Should check if $1 exists, output to $1 file. If not specified, output to screen
	if [ -f "$1" ]
		then
		echo "File $1 exists, try another filename"
		exit 1
	fi
	cpus=$( ls -d /sys/devices/system/cpu/cpu[[:digit:]]* | wc -w )
	
#	for f in *.jpg
#	do	
	#	if [ -z "$1" ]
	#		then 
				ls *.jpg | xargs -n 1 -P $cpus tessafile 
	#		else 
	#			echo "$f---    " >> "$1"
	#			tesseract -psm 8 "$f" stdout digits >> "$1"
	#	fi
#	done


