#!/bin/bash
# V0.2 tesseract ocr all jpg files in parallel
# Authur: John Xu
# Should check if $1 exists, output to $1 file. If not specified, output to screen
	if [ -f "$1" ]
		then
		tesseract -psm 8 "$1" stdout digits
	else
		echo "Usage: tessafile filename"
		exit 1
	fi


