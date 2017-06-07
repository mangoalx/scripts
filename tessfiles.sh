#!/bin/bash
# V0.1 tesseract ocr all jpg files
# Authur: John Xu
# Should check if $1 exists, output to $1 file. If not specified, output to screen
	if [ -f "$1" ]
		then
		echo "File $1 exists, try another filename"
		exit 1
	fi

	for f in *.jpg
	do
		if [ -z "$1" ]
			then 
				tesseract -psm 8 "$f" stdout digits 
			else 
				echo "$f---    " >> "$1"
				tesseract -psm 8 "$f" stdout digits >> "$1"
		fi
	done


