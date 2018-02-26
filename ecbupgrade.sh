#!/bin/bash
# 
# by John Xu
# For ON.6U ECB firmware and control table upgrade
# Version 0.1
#	- Help and version message
#	+ Sending upgrade command
#	- Ask for confirmation before continue
#	* read control table back
#	* generate .inf files for firmware .bin and control table .bin if missing

############ Functions
version()
{
	echo "ecbupgrade.sh version 0.1"
}
usage()
{
	version
    echo "usage: ecbupgrade [-h] | [-v] | [-s SerialNo] ([-r] | [[-f fwFilename] [-t tableFilename]])"
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-r or --rollback to rollback both firmware and control table to the version that is bundled in the VLE"
	echo "-f or --firmware to upgrade firmware"
	echo "      fwFilename: specify the firmware binary file. Use \"\" to rollback firmware"
	echo "-t or --table to upgrade control table"
	echo "      tableFilename: specify the table binary file. Use \"\" to rollback control table"
	echo "-s or --serial to specify the desired device when multiple adb devices are present" 
	echo "      SerialNo: the serial number of the device to be upgraded"
}

############ main
serial= 
action=0

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
		-r | --rollback)
								action=$((action + 100))
								;;
		-f | --firmware)		shift
								fwFilename=$1
								action=$((action + 1))
								;;
		-t | --table)			shift
								tableFilename=$1
								action=$((action + 10))
								;;
		-s | --serial)			shift
								serial=$1
								;;
        * )                     echo "Unknown parameter"
								usage
								exit
                                
    esac
    shift
done
#echo "$action"
if [ -z "$serial" ]
	then
		adbc="adb shell"
	else adbc="adb -s $serial shell"
fi
case $action in
	0)			usage
				exit
				;;
	1)			#upgrade or rollback firmware only
				adbc="$adbc 'am broadcast -a com.videri.ecbservice.ECB_SET_CUSTOM_FIRMWARE_ACTION --es ECB_SET_CUSTOM_FIRMWARE_EXTRA_APP_PATH \"$fwFilename\" '"
				message="Firmware will be upgraded with file $fwFilename"
				;;
	10)			#upgrade or rollback control table only
				adbc="$adbc 'am broadcast -a com.videri.ecbservice.ECB_SET_CUSTOM_FIRMWARE_ACTION --es ECB_SET_CUSTOM_FIRMWARE_EXTRA_TABLE_PATH \"$tableFilename\" '"
				message="Control table will be upgraded with file $tableFilename"
				;;
	11)			#upgrade or rollback both fimware and control table
				adbc="$adbc 'am broadcast -a com.videri.ecbservice.ECB_SET_CUSTOM_FIRMWARE_ACTION --es ECB_SET_CUSTOM_FIRMWARE_EXTRA_APP_PATH \"$fwFilename\" \
--es ECB_SET_CUSTOM_FIRMWARE_EXTRA_TABLE_PATH \"$tableFilename\" '"
				message="Firmware will be upgraded with file $fwFilename and Control table will be upgraded with file $tableFilename"
				;;
	100)		#rollback both fimware and control table
				adbc="$adbc 'am broadcast -a com.videri.ecbservice.ECB_SET_CUSTOM_FIRMWARE_ACTION --es ECB_SET_CUSTOM_FIRMWARE_EXTRA_APP_PATH \"\" \
--es ECB_SET_CUSTOM_FIRMWARE_EXTRA_TABLE_PATH \"\" '"
				message="Both firmware and control table will be rolled back"
				;;
	*)			echo "Error: incorrect command format"
				usage
				exit
esac
#echo "$adbc"
echo "$message"
read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	$adbc 
    # do dangerous stuff
fi

