#!/bin/bash
# Readkey then send key input via adb
# Authur: John Xu
# Should check if $1 exists then use -s option

# Reset terminal to current state when we exit.
trap "stty $(stty -g)" EXIT

# Disable echo and special characters, set input timeout to 0.2 seconds.
stty -echo -icanon time 2 || exit $?

# String containing all keypresses.
KEYS=""

# Set field separator to BEL (should not occur in keypresses)
IFS=$'\a'

clear
echo "This script is used for sending keyboard input to device via adb connection"
echo "Useage: adbkeyin [serialNo]"
echo "Key assignments: "
echo "PageUp - Enter        PageDown - Menu"
echo "Esc - Back            End - Power"
echo "Insert - Search       Delete - Backspace"
echo "Use Arrow keys to move focus around"
echo "Use alpha-num key to input. Some symbol not supported"

# Remind user to press ESC to quit.
echo "Press Ctrl+C to quit." >&2


#initialize keycode to 0, this will be send to device via adb shell input keyevent command
	keycode=0
#If device serial no. is specified, put it in serial for use in sub-functions
	if [ -z "$1" ]
		then serial=""
	else serial="$1"
	echo "Sending key input to device $serial"
	fi

#Use this function to send keycode to the device
	function sendCommand() {
		if [ -z "$serial" ]
			then adb shell input keyevent $keycode
			else adb -s "$serial" shell input keyevent $keycode
		fi
	}
#Use this function to sent text input to the device
	function sendText() {
		while true; do
		    case "$KEYS" in
			[0-9]*|[a-z]*|[A-Z]*)
		        KEY+="${KEYS:0:1}"
        		KEYS="${KEYS#?}"
				;;
			*) break
				;;
			esac
		done
#		echo "${KEY}"
		if [ -z "$serial" ]
			then adb shell input text "${KEY}"
			else adb -s "$serial" shell input text "${KEY}"
		fi
	}

# Input loop.
while [ 1 ]; do

    # Read more input from keyboard when necessary.
    while read -t 0 ; do
        read -s -r -d "" -N 1 -t 0.2 CHAR && KEYS="$KEYS$CHAR" || break
    done

    # If no keys to process, wait 0.05 seconds and retry.
    if [ -z "$KEYS" ]; then
        sleep 0.05
        continue
    fi

    # Check the first (next) keypress in the buffer.
    case "$KEYS" in
      $'\x1B\x5B\x41'*) # Up
        KEYS="${KEYS##???}"
		keycode=19; sendCommand;;
#        echo "Up"
#        ;;
      $'\x1B\x5B\x42'*) # Down
        KEYS="${KEYS##???}"
		keycode=20; sendCommand;;
#        echo "Down"
#        ;;
      $'\x1B\x5B\x44'*) # Left
        KEYS="${KEYS##???}"
		keycode=21; sendCommand;;
#        echo "Left"
#        ;;
      $'\x1B\x5B\x43'*) # Right
        KEYS="${KEYS##???}"
		keycode=22; sendCommand;;
#        echo "Right"
#        ;;
      $'\x1B\x4F\x48'*) # Home
        KEYS="${KEYS##???}"
		keycode=3; sendCommand;;
#        echo "Home"
#        ;;
      $'\x1B\x5B\x31\x7E'*) # Home (Numpad)
        KEYS="${KEYS##????}"
		keycode=3; sendCommand;;
#        echo "Home (Numpad)"
#        ;;
      $'\x1B\x4F\x46'*) # End
        KEYS="${KEYS##???}"
		keycode=26; sendCommand;;		#End, as Power key
#        echo "End"
#        ;;
      $'\x1B\x5B\x34\x7E'*) # End (Numpad)
        KEYS="${KEYS##????}"
		keycode=26; sendCommand;;		#End, as Power key
#        echo "End (Numpad)"
#        ;;
      $'\x1B\x5B\x45'*) # 5 (Numpad)
        KEYS="${KEYS#???}"
		keycode=23; sendCommand;;		#Center
#        echo "Center (Numpad)"
#        ;;
      $'\x1B\x5B\x35\x7e'*) # PageUp
        KEYS="${KEYS##????}"
		keycode=66; sendCommand;;		#PageUp as Enter
#        echo "PageUp"
#        ;;
      $'\x1B\x5B\x36\x7e'*) # PageDown
        KEYS="${KEYS##????}"
		keycode=82; sendCommand;;		#PageDown as Menu
#        echo "PageDown"
#        ;;
      $'\x1B\x5B\x32\x7e'*) # Insert
        KEYS="${KEYS##????}"
		keycode=84; sendCommand;;		#Insert for search
#        echo "Insert"
#        ;;
      $'\x1B\x5B\x33\x7e'*) # Delete
        KEYS="${KEYS##????}"
		keycode=67; sendCommand;;		#Delete
#        echo "Delete"
#        ;;
      $'\n'*|$'\r'*) # Enter/Return
        KEYS="${KEYS##?}"
		keycode=66; sendCommand;;		#Enter        
#		echo "Enter or Return"
#        ;;
      $'\t'*) # Tab
        KEYS="${KEYS##?}"
        echo "Tab"
        ;;
      $'\x1B') # Esc (without anything following!)
        KEYS="${KEYS##?}"
		keycode=4; sendCommand;;		#Esc as Back
#       echo "Esc - Quitting"
#       exit 0
#        ;;
      $'\x1B'*) # Unknown escape sequences
        echo -n "Unknown escape sequence (${#KEYS} chars): \$'"
        echo -n "$KEYS" | od --width=256 -t x1 | sed -e '2,99 d; s|^[0-9A-Fa-f]* ||; s| |\\x|g; s|$|'"'|"
        KEYS=""
        ;;
	  $'\\'*) 
        KEYS="${KEYS##?}"
		keycode=73; sendCommand;;		#Backslash
	  $'#'*) 
        KEYS="${KEYS##?}"
		keycode=18; sendCommand;;		#Pound key
	  $'*'*) 
        KEYS="${KEYS##?}"
		keycode=17; sendCommand;;		#Star key

      [$'\x01'-$'\x1F'$'\x7F']*) # Consume control characters
        KEYS="${KEYS##?}"
        ;;
      *) # Printable characters.
        KEY="${KEYS:0:1}"
        KEYS="${KEYS#?}"
		sendText						#Text input
#        echo "'$KEY'"
       	;;
    esac
done
