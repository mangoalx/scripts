#!/bin/bash

if [ "$1" = "" ]; then
	echo "Usage: $0 <mp4>"
	exit 1
fi

input="$1"

if [ ! -f "$input" ]; then
	echo "File [$input] does not exist"
	exit 1
fi

output="$input.txt"

echo "Converting [$input] to [$output]..."

tmpdir="${input}-png"

rm "${tmpdir}/*.png" > /dev/null 2>&1
rmdir "${tmpdir}" > /dev/null 2>&1
mkdir "${tmpdir}"

rm "${output}" > /dev/null 2>&1

 #~/bin/ffmpeg -i "$input" -vf eq=gamma=10.0:saturation=0.0:contrast=2.0 -vsync 0 "${tmpdir}"/%06d.png
 
# ~/bin/ffmpeg -i "$input" -vf eq=saturation=0.0:contrast=2.0 -vsync 0 "${tmpdir}"/%06d.png
ffmpeg -i "$input" -vf eq=saturation=0.0:contrast=2.0 -vsync 0 "${tmpdir}"/%06d.png

for f in "${tmpdir}"/*.png; do
	tesseract $f stdout >> "${output}" 2>/dev/null
done
