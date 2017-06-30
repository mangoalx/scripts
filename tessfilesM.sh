#!/bin/bash
# V0.2 	tesseract ocr all jpg files in parallel
#		- display progress indicator, 1) display total/100 chars '-', 2) in tessafile, display a '+' everytime filename ends with '00' to stderr 
#		All messages and progress indicator are directed to stderr so they won't mix with ocr outputs, user can direct ocr result to a file
# Authur: John Xu
# Should check if $1 exists, output to $1 file. If not specified, output to screen
set -o errexit				# to exit when a command failed
#set -e nounset				# to exit if undefined variable is used

	if [ -f "$1" ]
		then
		echo "File $1 exists, try another filename" >&2
		exit 1
	fi
	cpus=$( ls -d /sys/devices/system/cpu/cpu[[:digit:]]* | wc -w )

echo "Tesseracting images, please wait ... " >&2
	if [ -d "tmp/" ]
	then
		usingtmp=1 
		cd "tmp"
	else
		usingtmp=0
	fi
	count=0
	total=$(ls -1 *.jpg|wc -l)
	echo "Total jpg files: $total" >&2
	# For progress indicator ...	
	hundreds=$((total / 100)); 
	for ((i=1; i<=$hundreds; i++)); do echo -n '-'>&2; done	
	echo >&2			# New line, then the tessafile will display their progress here

	if [ -z "$1" ]
	then
		ls *.jpg | xargs -n 1 -P $cpus tessafile | sort
		if [ usingtmp=1 ]
		then
			cd ..
		fi
	else
		outname=$1
		if [ -f "$outname" ]
		then
			rm "$outname"
		fi
		ls *.jpg | xargs -n 1 -P $cpus tessafile | sort >> "$outname"
#		outname="ocrResult.txt" 
		if [ usingtmp=1 ]
		then
			mv "$outname" ../
			cd ..
		fi
	fi
	echo >&2

