#!/bin/bash
#
# Nexus 7 Setup Wi-fi
#
# Simple script to set up a Nexus 7 for a WPA2-Enterprise Wireless network
# with 802.1x authentication, which is broken in Android Jelly Bean. It 
# relies on rooting the device.
#
# This script is a work in progress. I am not responsible for any issues 
# that arise if you run this script with your device. Use at your own
# discretion.
#
# Last updated: August 24, 2012

[[ `whoami` != 'root' ]] && echo "Script must be run as root." && exit 1

PWD=`pwd`
RES="$PWD/res"
adb="$PWD/bin/adb"
fastboot="$PWD/bin/fastboot"
export PATH=$PATH:$PWD/bin/

# Prints the introductory message.
print-header() {
    clear
    echo "Welcome to the [private] Nexus 7 Wireless Setup Utility by Ian Naval.

This utility sets up a Nexus 7 device to work with the [private] Wireless. It requires
the device to have access to debugging mode. Designed for easy of use, this
script uses very easy-to-follow instructions.
"
}

# Informs the user that proceeding will wipe the device of its existing
# information and will void the warranty.
warning-prompt() {
    echo "Warning: using this script will have two very serious negative consequences:
1. Your device's warranty will be voided.
2. All of the data on your device will be deleted. Please back up all important
information before proceeding.
"
    read -p "Proceed? [y/n*] "
    [ "$REPLY" == "y" ] || exit 1
    clear
}

# Prints the instructions to register the device on the network.
net-reg-instructions() {
    echo "You need to make sure that your Nexus 7 is registered on the 
[private] network. To do so, follow these steps:

1. Visit [private] and log in using your UNIX account.
2. Click on 'register new machine'.
3. Select 'Wireless: Mobile Devices' from the IP address range list.
4. Choose a hostname for your device, and enter it into the field.
5. Unlock your Nexus 7 and go to Settings > About Tablet > Status
6. Enter your MAC address into the field, which is found in Step 5.
7. Choose the correct OS and optionally enter your serial number, etc.
8. Finish registering the machine.

Press [Enter] once you've completed that."
    read
    clear
}

# Check for connected in debug mode.
check-debug-mode() {
    STATE=`adb get-state`
    if [ $STATE != "device" ]; then
        echo "Device not found. Please double-check that your device is
connected via USB and that Debug Mode is enabled."
        echo
        debug-mode-instructions
        adb wait-for-device
    fi
    echo -e "An Android device was found in debug mode!\n"
}

# Printes the instructions to put the Nexus 7 into debug mode.
debug-mode-instructions() {
    echo "To put your device into debug mode, follow these instructions:
1. Press the home button.
2. Swipe down on your menu screen.
3. Tap the settings icon and select 'Developer options'.
4. Flip the switch to 'on' if needed and click 'OK'.
5. Check the box next to 'USB debugging' and click 'OK'.
"
}

# Unlock bootloader.
unlock-bootloader() {
    echo -e "Unlocking the bootloader.\n"
    adb reboot bootloader > /dev/null  # Reboot from debug mode.
    fastboot oem unlock
    echo "Use the volume up/down buttons to navigate the menu and use the
power button to select the highlighted item. Press power to confirm that your
device should be unlocked, and press [Enter] when the device finishes rebooting
and you can confirm the bootloader is unlocked.
"
    read
    clear
}

# Root device by flashing ClockworkMod Recovery and installing a su binary.
root-device() {
    echo "Rooting the device. Your device will reboot several times. Please do
not unplug your device until you are instructed.
"
    fastboot reboot-bootloader > /dev/null  # Reboot bootloader from bootloader.
    echo "Flashing ClockworkMod Recovery."
    sleep 2
    fastboot flash recovery $RES/recovery.img
    echo -e "Waiting for device to reboot.\n"
    sleep 5
    fastboot reboot > /dev/null
    adb wait-for-device > /dev/null
    sleep 1
    echo -e "Pushing SuperSU.zip to /sdcard/\n"
    adb push $RES/SuperSU.zip /sdcard/ > /dev/null
    echo -e "Booting into ClockworkMod Recovery.\n"
    adb reboot recovery > /dev/null
    clear
    echo "Follow these instructions VERY carefully:
1. Press the volume down key once to highlight 'install zip from sdcard'.
2. Press the power button once to select it.
3. Press the power button once again to select 'choose zip from sdcard'.
4. Press the volume up key until 'SuperSU.zip' is highlighted
5. Press the power button once to select it.
6. Press the volume down key until 'Yes - Install SuperSU.zip' is highlighted.
7. Press the power button once to select it.
8. Press the up key once to select '+++++Go Back+++++'.
9. Press the power button once to select it.
10. Press the power button once again to reboot the system now.

Use the power and volume buttons to confirm that you want to keep the
ClockworkMod Recovery bootloader permanently.
"
    read
}

# Mount /system as read/write.
mount-read-write() {
    adb wait-for-device
    echo "Mounting the system as read/write."
    adb shell su -c 'mount -o remount,rw /system'
    echo
}

# Back up the bad config library into a separte file.
fix-config() {
    adb wait-for-device
    echo "Fixing the configuration library."
    adb shell su -c 'mv /system/lib/hw/keystore.grouper.so /system/lib/hw/keystore.grouper.so.bak'
    echo "Rebooting the device into normal mode one final time."
    adb reboot
    echo
}

# Pushes the certificate files.
push-certificate-files() {
    adb wait-for-device
    echo "Pushing the certificate files to your device."
    adb push $RES/[private] /sdcard/
    adb push "$RES/[private]" /sdcard/
    echo
}

# Printes instructions for configuring Wi-Fi.
print-configuration-instructions() {
    echo "Now you must configure your Wi-Fi:

1. Go to Settings > Security.
2. Set up a 'Screen lock' if you haven't already. Follow the on-screen
instructions for more details. I recommend setting up a pattern.
3. Tap 'Install from storage'.
4. Tap '[private]'.
5. Type this password: [private]
6. Type 'OK' on the dialog box 'Name the certificate.'
7. Verify your identity by entering the pattern, PIN or password you set up.
8. Tap '[private]' and then 'OK' on the dialog box.
9. Press the back arrow, scroll up, and tap on 'Wi-Fi'.
10. Tap on '[private]' and configure the following settings:

EAP method: TLS
Phase 2 authentication: None
CA certificate: [private]
User certificate: [private]
Identity: [private]
Anonymous Identity: (leave blank)
Password: (leave blank)

11. Click Connect.

Press [Enter] when you have completed these steps.
"
    read
    clear
}

# Prints the instructions to download the certificate files.
download-certificate-instructions() {
    echo "Now comes the final steps to prepare your device for connecting to the
[private] network.
"
    echo "1. Go to Settings > Security and tap 'Clear security credentials'.
2. Visit [private] on your Nexus 7 and download the two files under
the Android header.
3. Open your Downloads and install each individual certificate. The [private]
should be named appropriately: [private].
4. Reconfigure your Wi-Fi settings to use the new certifcates:

Press [Enter] for detailed instructions on Step 4."
    read
}

print-success() {
    echo "Congratulations! Your rooted Nexus 7 is now ready to connect to the
[private] network. If it doesn't work immediately, please wait at least 30 more
minutes for the device's address to finish registering in the network.

The [private] Helpdesk does not support the Nexus 7, so if you run into any
problems, please contact Ian Adam Naval at [private]."
}

# The main function that calls all of the other functions in series.
run() {
    print-header
    warning-prompt
    net-reg-instructions
    check-debug-mode
    unlock-bootloader
    root-device
    check-debug-mode
    mount-read-write
    fix-config
    push-certificate-files
    print-configuration-instructions
    download-certificate-instructions
    print-configuration-instructions
    print-success
}

run
