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

echo ds2482 0x18 > /sys/devices/soc.0/f9965000.i2c/i2c-9/new_device
echo ds2482 0x19 > /sys/devices/soc.0/f9965000.i2c/i2c-9/new_device
echo lcc600 0x5e > /sys/devices/soc.0/f9965000.i2c/i2c-9/new_device
insmod /system/lib/modules/ina2xx.ko                                  > /dev/null 2>&1
insmod /system/lib/modules/gpio-pca953x.ko                            > /dev/null 2>&1
insmod /system/lib/modules/pmbus_core.ko                              > /dev/null 2>&1
insmod /system/lib/modules/lcc600.ko                                  > /dev/null 2>&1
insmod /system/lib/modules/hdc1008.ko                                 > /dev/null 2>&1
insmod /system/lib/modules/ds2482.ko                                  > /dev/null 2>&1
insmod /system/lib/modules/jc42.ko                                    > /dev/null 2>&1
insmod /system/lib/modules/isl29018.ko                                > /dev/null 2>&1
I2C_BASE_PATH="/sys/class/i2c-dev/i2c-9/device/9-00"

# Read from 1-wire temperature sensor
#error_check "sed -n '{N;s/^.*YES.*t=\(-\?[[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master2/$(head -n 1 /sys/bus/w1/devices/w1_bus_master2/w1_master_slaves)/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"
#error_check "sed -n '{N;s/^.*YES.*t=\([[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master1/$(head -n 1 /sys/bus/w1/devices/w1_bus_master1/w1_master_slaves)/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"
#error_check "sed -n '{N;s/^.*YES.*t=\([[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master1/`head -n 1 /sys/bus/w1/devices/w1_bus_master1/w1_master_slaves`/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"
error_check "sed -n '{N;s/^.*YES.*t=\([[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master2/`head -n 1 /sys/bus/w1/devices/w1_bus_master2/w1_master_slaves`/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"
# Read from mcp9808s
error_check "cat ${I2C_BASE_PATH}1c/temp1_input"    "mcp9808-0x1c-temperature"
error_check "cat ${I2C_BASE_PATH}1e/temp1_input"    "mcp9808-0x1e-temperature"
# Read from hdc1080
error_check "cat ${I2C_BASE_PATH}40/temp1_input"    "hdc1080-0x40-temperature"
error_check "cat ${I2C_BASE_PATH}40/humrel1_input"  "hdc1080-0x40-humidity"
# Read from ina220s
error_check "cat ${I2C_BASE_PATH}41/in1_input"      "ina220-0x41-voltage"
error_check "cat ${I2C_BASE_PATH}41/curr1_input"    "ina220-0x41-current"
error_check "cat ${I2C_BASE_PATH}41/power1_input"   "ina220-0x41-power"
error_check "cat ${I2C_BASE_PATH}42/in1_input"      "ina220-0x42-voltage"
error_check "cat ${I2C_BASE_PATH}42/curr1_input"    "ina220-0x42-current"
error_check "cat ${I2C_BASE_PATH}42/power1_input"   "ina220-0x42-power"
error_check "cat ${I2C_BASE_PATH}45/in1_input"      "ina220-0x45-voltage"
error_check "cat ${I2C_BASE_PATH}45/curr1_input"    "ina220-0x45-current"
error_check "cat ${I2C_BASE_PATH}45/power1_input"   "ina220-0x45-power"
error_check "cat ${I2C_BASE_PATH}46/in1_input"      "ina220-0x46-voltage"
error_check "cat ${I2C_BASE_PATH}46/curr1_input"    "ina220-0x46-current"
error_check "cat ${I2C_BASE_PATH}46/power1_input"   "ina220-0x46-power"
error_check "cat ${I2C_BASE_PATH}4a/in1_input"      "ina220-0x4a-voltage"
error_check "cat ${I2C_BASE_PATH}4a/curr1_input"    "ina220-0x4a-current"
error_check "cat ${I2C_BASE_PATH}4a/power1_input"   "ina220-0x4a-power"
error_check "cat ${I2C_BASE_PATH}4b/in1_input"      "ina220-0x4b-voltage"
error_check "cat ${I2C_BASE_PATH}4b/curr1_input"    "ina220-0x4b-current"
error_check "cat ${I2C_BASE_PATH}4b/power1_input"   "ina220-0x4b-power"
error_check "cat ${I2C_BASE_PATH}4c/in1_input"      "ina220-0x4c-voltage"
error_check "cat ${I2C_BASE_PATH}4c/curr1_input"    "ina220-0x4c-current"
error_check "cat ${I2C_BASE_PATH}4c/power1_input"   "ina220-0x4c-power"
# Read from lcc600
error_check "cat ${I2C_BASE_PATH}5e/in1_input"      "lcc600-0x5e-ac-voltage"
error_check "cat ${I2C_BASE_PATH}5e/in2_input"      "lcc600-0x5e-24-voltage"
error_check "cat ${I2C_BASE_PATH}5e/curr1_input"    "lcc600-0x5e-current"
error_check "cat ${I2C_BASE_PATH}5e/power1_input"   "lcc600-0x5e-power"
error_check "cat ${I2C_BASE_PATH}5e/temp1_input"    "lcc600-0x5e-temperature1"
error_check "cat ${I2C_BASE_PATH}5e/temp2_input"    "lcc600-0x5e-temperature2"
error_check "cat ${I2C_BASE_PATH}5e/temp3_input"    "lcc600-0x5e-temperature3"
# Read from isl29023
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_illuminance0_input"  "isl29023-0x44-illuminance"
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_intensity_ir_raw"    "isl29023-0x44-intensity_ir_raw"
error_check "cat ${I2C_BASE_PATH}44/iio:device0/in_proximity_raw"       "isl29023-0x44-proximity_raw"

#rmmod isl29018.ko                                > /dev/null 2>&1
#rmmod jc42.ko                                    > /dev/null 2>&1
#rmmod ds2482.ko                                  > /dev/null 2>&1
#rmmod hdc1008.ko                                 > /dev/null 2>&1
#rmmod lcc600.ko                                  > /dev/null 2>&1
#rmmod gpio-pca953x.ko                            > /dev/null 2>&1
#rmmod pmbus_core.ko                              > /dev/null 2>&1
#rmmod ina2xx.ko                                  > /dev/null 2>&1
