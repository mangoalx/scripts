#!/bin/bash

TEXT1="\
%{eif\\\\:if(bitand(n\,2^15)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^14)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^13)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^12)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^11)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^10)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^9)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^8)\,1)\\\\:d}"

TEXT2="\
%{eif\\\\:if(bitand(n\,2^7)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^6)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^5)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^4)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^3)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^2)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^1)\,1)\\\\:d}\
%{eif\\\\:if(bitand(n\,2^0)\,1)\\\\:d}"


# ~/bin/ffmpeg -f lavfi -i color=c=white:s=400x200:rate=60 \
# -vf "[in]\
# drawtext=fontfile=/usr/share/fonts/truetype/droid/DroidSansMono.ttf:fontsize=60: fontcolor=black: x=(w-text_w)/2: y=(1*h/4-text_h/2): text=${TEXT1},\
# drawtext=fontfile=/usr/share/fonts/truetype/droid/DroidSansMono.ttf:fontsize=60: fontcolor=black: x=(w-text_w)/2: y=(3*h/4-text_h/2): text=${TEXT2}\
# [out]" -vcodec h264 counter.mp4

~/bin/ffmpeg -f lavfi -i color=c=white:s=800x200:rate=60 \
-vf "drawtext=fontfile=/usr/share/fonts/truetype/droid/DroidSansMono.ttf:fontsize=60: fontcolor=black: x=(w-text_w)/2: y=(h/2-text_h/2): text=${TEXT1}${TEXT2}" -vcodec h264 counter-2.mp4