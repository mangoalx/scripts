#!/system/bin/sh

TAG="${0##*/}"
VOLT_12_LOW="11500"
VOLT_12_HIGH="12500"
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

setup_gpio() {
    echo $1 > /sys/class/gpio/export
    echo $2 > /sys/class/gpio/gpio"$1"/direction    
}
set_gpio() {
    echo $2 > /sys/class/gpio/gpio"$1"/value    
}

#check value range value, min val, max val, name
check_value() {
    PARAM="$(eval ${1} 2>&1)"       
    if [ $? -ne 0 ]; then
        echo "${2}: ERROR -- ${PARAM}"
    else        
        if [ $PARAM -lt $3 ]; then
            echo"$2 $PARAM is too low     FAIL" 
        else
            if [ "$PARAM" -gt $4 ]; then        
                echo "$2 $PARAM is too high     FAIL"
            else
                echo "$2 $PARAM is within Range PASS" 
            fi
        fi
    fi 
}

# ON 6X v3.5 assembly I/O test script
#i2cdetect -y 9

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
error_check "sed -n '{N;s/^.*YES.*t=\([[:digit:]]*\).*/\1/p}' /sys/bus/w1/devices/w1_bus_master1/$(head -n 1 /sys/bus/w1/devices/w1_bus_master1/w1_master_slaves)/w1_slave | grep -v '^$'" "w1_slave-0x19-temperature"
# Read from mcp9808s
i2cset -y -f 9 0x74 0x07 0x0F
i2cset -y -f 9 0x74 0x03 0xF0

sleep 0.5

echo "9-001a" > /sys/bus/i2c/drivers/jc42/bind
echo "9-001b" > /sys/bus/i2c/drivers/jc42/bind
echo "9-001c" > /sys/bus/i2c/drivers/jc42/bind
echo "9-001e" > /sys/bus/i2c/drivers/jc42/bind

sleep 0.5

check_value "cat ${I2C_BASE_PATH}1a/temp1_input"    "mcp9808-0x1a-temperature" 17000 28000
check_value "cat ${I2C_BASE_PATH}1b/temp1_input"    "mcp9808-0x1b-temperature" 17000 28000
check_value "cat ${I2C_BASE_PATH}1c/temp1_input"    "mcp9808-0x1c-temperature" 17000 28000
check_value "cat ${I2C_BASE_PATH}1e/temp1_input"    "mcp9808-0x1e-temperature" 17000 28000


#try to disable the I2C for each channel

i2cset -y -f 9 0x74 0x03 0xE0
sleep 1
cat ${I2C_BASE_PATH}1a/temp1_input 
if [ "$?" = "0" ]; then
    echo "FAIL I2C disable 1"
fi

i2cset -y -f 9 0x74 0x03 0xD0
sleep 1
cat ${I2C_BASE_PATH}1b/temp1_input 
if [ "$?" = "0" ]; then
    echo "FAIL I2C disable 2"
fi

i2cset -y -f 9 0x74 0x03 0xB0
sleep 1
cat ${I2C_BASE_PATH}1c/temp1_input 
if [ "$?" = "0" ]; then
    echo "FAIL I2C disable 3"
fi

i2cset -y -f 9 0x74 0x03 0x70
sleep 1
cat ${I2C_BASE_PATH}1e/temp1_input 
if [ "$?" = "0" ]; then
    echo "FAIL I2C disable 4"
fi
#reset everything back to inputs
i2cset -y -f 9 0x74 0x07 0xFF

#check volatage ranges 
check_value "cat ${I2C_BASE_PATH}41/in1_input" "ina220-0x41-voltage 12V Main" 11500 12500
check_value "cat ${I2C_BASE_PATH}42/in1_input" "ina220-0x42-voltage 12V AUX " 11500 12500
check_value "cat ${I2C_BASE_PATH}45/in1_input" "ina220-0x45-voltage 24V In  " 23000 26000
check_value "cat ${I2C_BASE_PATH}46/in1_input" "ina220-0x46-voltage 5V Main " 4600 5400
check_value "cat ${I2C_BASE_PATH}4a/in1_input" "ina220-0x4a-voltage 5V AUX  " 4600 5400
check_value "cat ${I2C_BASE_PATH}4b/in1_input" "ina220-0x4b-voltage 3V3     " 3100 3500
check_value "cat ${I2C_BASE_PATH}4c/in1_input" "ina220-0x4c-voltage RTC BAT " 2300 4000

#now check the ability to turn off the aux inputs
setup_gpio 104 out
#setup_gpio 105 out
#setup_gpio 106 out
#turn off 12V AUX
set_gpio 104 1
#delay to let it go down
sleep 2
check_value "cat ${I2C_BASE_PATH}42/in1_input" "ina220-0x42-voltage 12V AUX OFF" 0 4000
set_gpio 104 0
#turn off 5V AUX
#set_gpio 105 0
#check_value "cat ${I2C_BASE_PATH}4a/in1_input" "ina220-0x4a-voltage 5V AUX OFF" 0 200
#check_value "cat ${I2C_BASE_PATH}4b/in1_input" "ina220-0x4b-voltage 3V3 OFF" 0 200
#set_gpio 105 1
#turn off 3V3 
#set_gpio 106 1
sleep 2
#check_value "cat ${I2C_BASE_PATH}4b/in1_input" "ina220-0x4b-voltage 3V3 OFF   " 0 1000
#set_gpio 106 0
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
