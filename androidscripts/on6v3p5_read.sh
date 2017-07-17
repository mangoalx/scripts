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
I2C_BASE_PATH="/sys/class/i2c-dev/i2c-9/device/9-00"

# Read from 1-wire temperature sensor
#error_check "sed -n '{N;s/^.*YES.*t=\([[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master1/$(head -n 1 /sys/bus/w1/devices/w1_bus_master1/w1_master_slaves)/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"
#error_check "sed -n '{N;s/^.*YES.*t=\([[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master1/`head -n 1 /sys/bus/w1/devices/w1_bus_master1/w1_master_slaves`/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"
# Read from isl29023
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_illuminance0_input"  "isl29023-0x44-illuminance"
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_intensity_ir_raw"    "isl29023-0x44-intensity_ir_raw"
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_proximity_raw"       "isl29023-0x44-proximity_raw"


