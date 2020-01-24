#!/bin/bash

id="6" # i2c bus 6
TAG="${0##*/}"

total_loops=0

error_count=0
count40=0
count41=0
count44=0
count45=0
count46=0
count48=0
count4d=0
count6f=0

error_check() {
    MESSAGE="$(eval ${1} 2>&1)"
    if [ $? -ne 0 ]; then
        echo "${TAG}: Command: ${1} Error: ${MESSAGE}"
        if [[ ${1} != *"new_device"* ]];
        then
            let '++error_count'
            case "${MESSAGE}" in
                *-0040* ) let '++count40';;
                *-0041* ) let '++count41';;
                *-0044* ) let '++count44';;
                *-0045* ) let '++count45';;
                *-0046* ) let '++count46';;
                *-0048* ) let '++count48';;
                *-004d* ) let '++count4d';;
                *-006f* ) let '++count6f';;
            esac
        fi
    else
        echo $MESSAGE
    fi
}

create_devices(){
    echo "$TAG creating i2c devices"
    error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
    error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
    error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    error_check "echo isl29018 0x44 > /sys/class/i2c-dev/i2c-$id/device/new_device"

}


stress_sensors()
{
    while true;
    do
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0040/iio\:device*/in_humidityrelative_raw"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0040/iio\:device*/in_temp_raw"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/power1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0045/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0045/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0045/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0045/hwmon/hwmon*/power1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0046/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0046/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0046/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0046/hwmon/hwmon*/power1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-004d/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-004d/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-004d/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-004d/hwmon/hwmon*/power1_input"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0044/iio\:device*/in_illuminance0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0044/iio\:device*/in_intensity_ir_raw"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0048/hwmon/hwmon*/temp1_input"

        # TODO: check that this command works
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-006f/rtc/rtc*/time"
        # error_check i2cget -y 6 0x6f 0x00

        let "++total_loops"

        read -t 0.005 -N 1 REPLY

        if [[ $REPLY == q ]];
        then
            echo
            break
        fi
    done
}

print_result()
{
    echo "Total Loops of Senor Polls = $total_loops"
    echo "Total Error Count = $error_count"
    echo "Error Count for 0x40 = $count40"
    echo "Error Count for 0x41 = $count41"
    echo "Error Count for 0x44 = $count44"
    echo "Error Count for 0x45 = $count45"
    echo "Error Count for 0x46 = $count46"
    echo "Error Count for 0x48 = $count48"
    echo "Error Count for 0x4d = $count4d"
    echo "Error Count for 0x6f = $count6f"
}

main(){
    # create the i2c devices/load the drivers
    create_devices

    # read all i2c sensors until q is pressed
    stress_sensors

    print_result
}

main