#!/bin/bash
# Readkey then send key input via adb
# Authur: John Xu
# Should check if $1 exists then use -s option
clear
echo "This script is used for sending keyboard input to device via adb connection"
echo "Useage: adbkeyin [serialNo]"
echo "Key assignments: "
echo "PageUp - Enter        PageDown - Menu"
echo "Esc - Back            End - Power"
echo "Insert - Search       Delete - Backspace"
echo "Use Arrow keys to move focus around"
echo "Use alpha-num key to input. Some symbol not supported"
	keycode=0
	if [ -z "$1" ]
		then serial=""
	else serial="$1"
	echo "Sending key input to device $serial"
	fi
  ReadKey() {
    # Wait for first char
    if read -sN1 _REPLY; then
      # Read rest of chars
      while read -sN1 -t 0.001 ; do
        _REPLY+="${REPLY}"
      done
    fi
  }
	function sendCommand() {
		if [ -z "$serial" ]
			then adb shell input keyevent $keycode
			else adb shell -s "$serial" input keyevent $keycode
#		adb -s "$1" shell cat /sys/devices/virtual/thermal/thermal_zone11/temp
		fi
	}
	function sendText() {
		if [ -z "$serial" ]
			then adb shell input text "${_REPLY}"
			else adb shell -s "$serial" input text "${_REPLY}"
		fi
	}

  while ReadKey  ; do
#    echo -e "${_REPLY}";
    case "${_REPLY}" in
		$'\e')		keycode=4; sendCommand;;		#Esc as Back
		$'\e[5~') 	keycode=66; sendCommand;;		#PageUp as Enter
		$'\e[6~') 	keycode=82; sendCommand;;		#PageDown as Menu
#		$'\n') keycode=66;  echo "\\n";sendCommand;;		#Enter
	
		$'\e[1~') ;&							#Home on numpad
		$'\eOH') keycode=3; sendCommand;;		#Home
		$'\e[4~') ;&							#End on numpad
		$'\eOF') keycode=26; sendCommand;;		#End, as Power key
		
		$'\e[A') keycode=19; sendCommand;;		#Up
		$'\e[B') keycode=20; sendCommand;;		#Down
		$'\e[C') keycode=22; sendCommand;;		#Right
		$'\e[D') keycode=21; sendCommand;;		#Left

		$'\e[2~') keycode=84; sendCommand;;		#Insert for search
		$'\e[3~') keycode=67; sendCommand;;		#Delete
		
		[\`\#\*\(\)\\\[\]\{\}\;\"\']) echo "\\ code not supported";;
# _REPLY='\'+"${_REPLY}";&
		[[:space:]]) keycode=62; sendCommand;;	#Send space
#		[\b\r\t\n]) keycode=62; sendCommand;;	#Send space
		[[:print:]]) sendText;;					#Text input
#      $'\e[1;2A') echo 'Shift + Up Arrow';;
#      $'\e[4~' | $'\e[4z') echo 'F4';;
#      $'\e[4;2~' | $'\e[4;2z') echo 'Shift + F4';;
      *) echo "Unknown, any others keys pressed: ${_REPLY}";;
    esac
  done


