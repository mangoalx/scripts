#!/bin/bash
# V0.1 Process video and get the dropped frame rate
# V0.2 Use ffmpeg to crop when extracting image files
# Authur: John Xu
# Should check if $1 exists, it is the video file. $2 is used as crop parameter. If not specified, do not crop
	
	if [ -f "$1" ]
	then
		if [ ! -z "$2" ]
		then
			cropsize="$2"				#Search and replace "x""+" with ":", so user can use imagemagick format parameter
			cropsize=${cropsize//x/\:}
			cropsize=${cropsize//+/\:}
			ffmpeg -i "$1" -vf "crop=$cropsize" frame-%06d.jpg
		else
			ffmpeg -i "$1" frame-%06d.jpg
#		then cropjpgs "$2"
		fi
		tessfiles output.txt
		python $HOME/software/scripts/python/checknum3.py output.txt >result.txt
		tail -n 3 result.txt
	else
		echo "checkskip <videofilename> [cropParameter]"
	fi


