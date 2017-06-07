#!/bin/bash
# Crop images to a same size
# Authur: John Xu
# 
clear
echo "This script is used to crop all jpg files in current folder"
echo "Useage: cropjpgs AAAxBBB+CCC+DDD"
echo "Where AAAxBBB is the jmage size after cropping"
echo "CCC+DDD is the offset where to start cropping"
echo "Use imageMagick to find out cropping geometry"
echo "Warning! Original files will be overwritten. Make your copy if needed"
if [ -z "$1" ]
	then
		echo "Useage: cropjpgs AAAxBBB+CCC+DDD"
		exit 1
fi
read -p "Press [Enter] key to continue, Ctrl+C to quit..."
for f in frame-*.jpg
do
   convert $f -crop $1 $f
done

