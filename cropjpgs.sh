#!/bin/bash
# Crop images to a same size

# Authur: John Xu
# 
clear
echo "This script is used to crop all jpg files in current folder"
if [ -z "$1" ]
	then
		echo "Useage: cropjpgs AAAxBBB+CCC+DDD"
		echo "Where AAAxBBB is the jmage size after cropping"
		echo "CCC+DDD is the offset where to start cropping"
		echo "Use imageMagick to find out cropping geometry"
		echo "Warning! Original files will be overwritten. Make your copy if needed"
		exit 1
fi
# read -p "Press [Enter] key to continue, Ctrl+C to quit..."
echo "Cropping ... Please wait"
	count=0
	total=$(ls -1 *.jpg|wc -l)
	for f in *.jpg
	do
		count=$[$count+1]
		convert $f -crop $1 $f
		echo -n "  $((${count}*100/${total})) %  "
		echo -n R | tr 'R' '\r'
	done
echo "Finished cropping jpgs "
