#!/bin/bash
# V0.1 tesseract ocr all jpg files
# V0.2 Add progress indicator
# Authur: John Xu
# Should check if $1 exists, output to $1 file. If not specified, output to screen
	if [ -f "$1" ]
		then
#		echo "File $1 exists, try another filename"
			rm $1
#		exit 1
	fi

echo "Tesseracting images, please wait ... "
	count=0
	total=$(ls -1 *.jpg|wc -l)

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
		echo -n "  $((${count}*100/${total})) %  "
		echo -n R | tr 'R' '\r'
	done
echo "Tesseracting finished, $total files in total"

