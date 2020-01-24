#!/bin/bash

TAG="${0##*/}"

GUID=a0999a12-8bbe-4255-ac0b-9534193407e7
EFIVAR_PATH="/sys/firmware/efi/efivars"

GET_EFIVAR()
{
    NAME=$1
    RET=""
    if [ $# -eq 1 ]; then
        if [ -f "${EFIVAR_PATH}/${NAME}-${GUID}" ]; then
            RET=$(tr -d '\0\a' < "${EFIVAR_PATH}/${NAME}-${GUID}")
        fi
    fi
    echo "${RET}"
}

partnumber=$(GET_EFIVAR PartNumber)
echo "$TAG: partnumber=[$partnumber]"

error_check() {
    MESSAGE="$(eval ${1} 2>&1)"
    if [ $? -ne 0 ]; then
        echo "${TAG}: Command: ${1} Error: ${MESSAGE}"
    else
        echo $MESSAGE
    fi
}

dump_sensors()
{
    # find correct i2c bus
    id=$(ls /sys/bus/pci/devices/0000\:00\:16.2/i2c_designware.2/ | grep i2c | cut -d "-" -f 2)
    # QSMi-R211
    echo "$TAG: dump i2c devices."
    if [ "$partnumber" = "VEN026QSNWM50" ]; then
        error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0040/iio\:device*/in_humidityrelative_raw"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0040/iio\:device*/in_temp_raw"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/power1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/power1_input"
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

    # CC48SMi
    elif [ "$partnumber" = "VEN048CSVXM00" ] || [ "$partnumber" = "VEN048CSVWM00" ]; then
        error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x42 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4e > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo isl29023 0x44 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0040/iio\:device*/in_humidityrelative_raw"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0040/iio\:device*/in_temp_raw"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/power1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/power1_input"
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
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-004e/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-004e/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-004e/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-004e/hwmon/hwmon*/power1_input"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0044/iio\:device*/in_illuminance0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0044/iio\:device*/in_intensity_ir_raw"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0048/hwmon/hwmon*/temp1_input"
    # QSMi
    elif [ "$partnumber" = "VEN026QSNWM00" ]; then
        error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"

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
    # 3SMi
    elif [ "$partnumber" = "VEN032FSNWM00" ]; then
        error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x42 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0040/iio\:device*/in_humidityrelative_raw"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0040/iio\:device*/in_temp_raw"

        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0041/hwmon/hwmon*/power1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/in0_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/in1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/curr1_input"
        error_check "cat /sys/class/i2c-dev/i2c-$id/device/$id-0042/hwmon/hwmon*/power1_input"
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
    fi
}

create_devices()
{
    # find correct i2c bus
    id=$(ls /sys/bus/pci/devices/0000\:00\:16.2/i2c_designware.2/ | grep i2c | cut -d "-" -f 2)
    # QSMi-R211
    echo "$TAG: create i2c and gpio devices."
    if [ "$partnumber" = "VEN026QSNWM50" ]; then
        error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    # CC48SMi
    elif [ "$partnumber" = "VEN048CSVXM00" ] || [ "$partnumber" = "VEN048CSVWM00" ]; then
        error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x42 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4e > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo isl29023 0x44 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    # QSMi
    elif [ "$partnumber" = "VEN026QSNWM00" ]; then
        error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    # 3SMi
    elif [ "$partnumber" = "VEN032FSNWM00" ]; then
        error_check "echo hdc1080 0x40 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x41 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x42 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x45 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x46 > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo ina220 0x4d > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo mcp7941x 0x6f > /sys/class/i2c-dev/i2c-$id/device/new_device"
        error_check "echo tmp275 0x48 > /sys/class/i2c-dev/i2c-$id/device/new_device"
    fi
    # set shunts??? 2000 for all; 1500 for VIN and Vbacklight?
    # CC48SMi VEN048CSVWM00
    # QSMi VEN026QSNWM00
    # 3SMi VEN032FSNWM00
    #
    # Dump all the sensors, none should fail
}

disable_wifi_bluetooth()
{
    if [ "$partnumber" = "VEN026QSNWM50" ]; then
        echo "$TAG: disable wifi"
        error_check "rfkill block wifi"

        echo "$TAG: disable bluetooth"
        error_check "rfkill block bluetooth"
    fi
}

main()
{
    # Create devices
    create_devices

    dump_sensors

    # Disable wifi&bluetooth accordingly
    disable_wifi_bluetooth
}

main
