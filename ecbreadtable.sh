#!/bin/bash
# 
# by John Xu
# For ON.6U ECB control table readback
#
#	* Need to be done
#	+ Completed but not tested
#	- Done and tested
#
# Version 0.1
#	- Help and version message
#	+ read control table back
#	* generate .inf files for firmware .bin and control table .bin if missing

############ Functions
version()
{
	echo "ecbreadtable.sh version 0.1"
}
usage()
{
	version
    echo "usage: ecbreadtable [-h] | [-v] | [-s SerialNo] [-t tempfilename] localfile"
	echo "-h or --help to display this message"
	echo "-v or --version to display version information"
	echo "-t or --tempfile to specify temporary filename on DPC, if ommitted, default name is /sdcard/devtable.bin"
	echo "      tempfilename: the temporary filename"
	echo "-s or --serial to specify the desired device when multiple adb devices are present" 
	echo "      SerialNo: the serial number of the device to be upgraded"
	echo "localfile: Is the path/filename where you want to put the readed table file, if ommitted it will be devtable.bin in the current folder"
}

############ main
serial= 
tempFilename="/sdcard/devtable.bin"
localFilename=

while [ "$1" != "" ]; do
    case $1 in
        -h | --help )           usage
                                exit
                                ;;
        -v | --version )        version
                                exit
                                ;;
		-t | --tempfile)		shift
								tempFilename=$1
								;;
		-s | --serial)			shift
								serial=$1
								;;
        * )                     localFilename=$1
								break				#parameters behind localFilename will ignored
                                
    esac
    shift
done

#if [ -z "$localFilename" ]
#	then
#		localFilename="devtable.bin"
#fi
if [ -z "$serial" ]
	then
		adbs="adb shell"
	else adbs="adb -s $serial shell"
fi
#adb shell am broadcast -a com.videri.ecbservice.ECB_GET_CURRENT_TABLE_ACTION --es ECB_GET_CURRENT_TABLE_EXTRA_PATH /sdcard/devtable.bin
#adb pull /sdcard/devtable.bin

adbc="$adbs 'am broadcast -a com.videri.ecbservice.ECB_GET_CURRENT_TABLE_ACTION --es ECB_GET_CURRENT_TABLE_EXTRA_PATH $tempFilename '"
echo "$adbc"
$adbc
sleep 5				#Wait for a while to let the reading finished
echo "$adbs pull $tempFilename $localFilename"
$adbs pull $tempFilename $localFilename

