#!/system/bin/sh

TAG="${0##*/}"

error_check() {
    # Execute and handle success/error
    MESSAGE="$(eval ${1} 2>&1)"
    if [ $? -ne 0 ]; then
        log -p e -t "${TAG}" "Command: ${1} Error: ${MESSAGE}"
        echo "${2}: ERROR -- ${MESSAGE}"
    else
        log -p d -t "${TAG}" "Command: ${1} Value: ${MESSAGE}"
        echo "${2}: SUCCESS -- ${MESSAGE}"
    fi
}

# ON 6X v3.5 assembly I/O test script

insmod /system/lib/modules/jc42.ko                                    > /dev/null 2>&1
I2C_BASE_PATH="/sys/class/i2c-dev/i2c-9/device/9-00"

# Read from mcp9808s
error_check "cat ${I2C_BASE_PATH}1c/temp1_input"    "mcp9808-0x1c-temperature"
error_check "cat ${I2C_BASE_PATH}1e/temp1_input"    "mcp9808-0x1e-temperature"

rmmod jc42.ko                                    > /dev/null 2>&1

