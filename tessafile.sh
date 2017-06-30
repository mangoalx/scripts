#!/bin/bash
# V0.1 tesseract single file, for ocr multithread process
# Authur: John Xu
# Should check if $1 exists. If not specified, show usage
	if [ -f "$1" ]
		then
		result=$(tesseract -psm 8 "$1" stdout digits)
		result="$1 ===$result"
		echo $result
		filename=$1
		anumber=${filename//[^0-9]/}
#		echo $anumber
		if [ $((10#$anumber%100)) == 0 ]
		then
			echo -n '+'>&2					# For progress indicator
		fi
	else
		echo "Usage: tessafile filename" >&2
		exit 1
	fi
#	echo
# astring="frame-000302.jpg";anumber=${astring//[^0-9]/};echo $((10#$anumber%100))
