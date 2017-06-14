#!/bin/bash
# V0.1 tesseract single file, for ocr multithread process
# Authur: John Xu
# Should check if $1 exists. If not specified, show usage
	if [ -f "$1" ]
		then
		result=$(tesseract -psm 8 "$1" stdout digits)
		result="$1 ===$result"
		echo $result
	else
		echo "Usage: tessafile filename"
		exit 1
	fi

