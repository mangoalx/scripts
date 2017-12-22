#!/system/bin/sh

TAG="${0##*/}"

insmod /system/lib/modules/gpio-pca953x.ko

echo 100 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio100/direction
echo 0 > /sys/class/gpio/gpio100/value

sleep 1 # assume default value was 0 and device is already mounted

DEVICE_NAME="$(eval grep -Hv ^0$ /sys/block/*/removable | sed -n 's/^.*\(sd.\).*/\1/p')"
BLOCK_NAME="$(eval ls /dev/block | sed -n "s/\(${DEVICE_NAME}.\)/\1/p")"

if [ -n "${BLOCK_NAME}" ]; then
    UUID1="$(eval blkid /dev/block/${BLOCK_NAME} | sed 's/^[^"].*UUID="\([^"]*\)".*/\1/')"
else
    UUID1=""
fi

echo 1 > /sys/class/gpio/gpio100/value

sleep 4 # wait for automount

DEVICE_NAME="$(eval grep -Hv ^0$ /sys/block/*/removable | sed -n 's/^.*\(sd.\).*/\1/p')"
BLOCK_NAME="$(eval ls /dev/block | sed -n "s/\(${DEVICE_NAME}.\)/\1/p")"

if [ -n "${BLOCK_NAME}" ]; then
    UUID2="$(eval blkid /dev/block/${BLOCK_NAME} | sed 's/^[^"].*UUID="\([^"]*\)".*/\1/')"
else
    UUID2=""
fi

if [ -n "${UUID1}" ] && [ -n "${UUID2}" ]; then
    if [ "${UUID1}" != "${UUID2}" ]; then
        echo "USB-SWITCH-TEST: PASS"
    else
        echo "USB-SWITCH-TEST: FAIL -- Switch failed, same UUID"
    fi
elif [ -n "${UUID1}" ]; then
    echo "USB-SWITCH-TEST: FAIL -- Device #2 not found"
elif [ -n "${UUID2}" ]; then
    echo "USB-SWITCH-TEST: FAIL -- Device #1 not found"
else
    echo "USB-SWITCH-TEST: FAIL -- No devices found"
fi

echo 0 > /sys/class/gpio/gpio100/value
echo 100 > /sys/class/gpio/unexport
rmmod gpio_pca953x
