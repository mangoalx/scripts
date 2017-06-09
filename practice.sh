#!/bin/bash
# 	
	if [ -f "$1" ]
		then
#		echo "File $1 exists, try another filename"
			rm $1
#		exit 1
	fi

	count=0
	total=$(ls -1 *.jpg|wc -l)
#	echo $total
#	echo "$((1000*100/${total}))%"

	for f in *.jpg
	do
		count=$[$count+1]
		if [ -z "$1" ]
			then 
				tesseract -psm 8 "$f" stdout digits 
			else 
				echo "$f---    " >> "$1"
				tesseract -psm 8 "$f" stdout digits >> "$1"
		fi
#		echo $count		
		echo -n "  $((${count}*100/${total})) %  "
		echo -n R | tr 'R' '\r'
#		echo
#		sleep 0.01
	done


