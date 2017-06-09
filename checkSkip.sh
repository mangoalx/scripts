#!/bin/bash
# V0.1 Process video and get the dropped frame rate
# Authur: John Xu
# Should check if $1 exists, it is the video file. $2 is used as crop parameter. If not specified, do not crop
	
	if [ -f "$1" ]
	then
		ffmpeg -i "$1" frame-%06d.jpg
		if [ ! -z "$2" ]
		then cropjpgs "$2"
		fi
		tessfiles output.txt
		python $HOME/software/scripts/python/checknum3.py output.txt >result.txt
		
	else
		echo "checkskip <videofilename> [cropParameter]"
	fi


