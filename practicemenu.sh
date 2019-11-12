#!/bin/bash
declare -A canvas_partno
canvas_partno=([VEN026QSNWM00]=QSMi [VEN032FSNWM00]=3SMi [VEN048CSVWM00]=CC48SMi)
errorCount=0

submenu () {
  local PS3='Please select a sensor to test (Enter to re-display the menu): '
  local options=(
		"40 - hdc1080 temp/humi" 
		"41 - ina220 Tcon 12V/10V" 
		"42 - ina220 VBB 12V/10V" 
		"44 - isl29023 ALS" 
		"45 - ina220 Vin 24V" 
		"46 - ina220 DPC 5V" 
		"48 - tmp275 Internal temp" 
		"4D - ina220 Backlight L 24V" 
		"4E - ina220 Backlight R 24V" 
		"6F - mcp7941x RTC/power_cycle" 
		"quit")
  local opt
  select opt in "${options[@]}"
  do
      case $opt in
          4*)
              echo "you chose $opt"
			  let "errorCount++"
			  echo $errorCount
              ;;
          6F*)
              echo "you chose option $REPLY for power cycle"
			  errorCount=0
              ;;
          "quit")
              return
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
}

echo "Videri OPCi Telemetry Test"
PS3='Please enter your choice (Enter to re-display the menu): '
options=("Automatically test based on partnumber"
		 "Manually choose sensor to test"
		 "Test QSMi"
		 "Test 3SMi"
		 "Test CC48SMi"
		 "Quit")
select opt in "${options[@]}"
do
	case $REPLY in
#		q) opt="${options[5]}";;
		a) opt="${options[0]}";;
		m) opt="${options[1]}";;
	esac
	  if [ $REPLY == "q" ];
		then
			 opt="Quit"
				echo "quit chosen"
	  fi
    case $opt in
		"Automatically test based on partnumber")
			echo ${!canvas_partno[*]}
			echo ${canvas_partno[*]}
			echo ${canvas_partno["unknown"]}
			;;
			
        "Manually choose sensor to test")
            submenu
            ;;
        "Test QSMi")
            echo "you chose Test QSMi"
            ;;
        "Test 3SMi")
            echo "you chose choice $REPLY which is $opt"
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY, opt is $opt";;
    esac
done
