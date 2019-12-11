date +%T;
echo "turning off fan.int.0"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 00 
sleep 3600
date +%T;
echo "turning on fan.int.0"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 01 
sleep 3600

date +%T;
echo "turning off fan.int.1"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 10
sleep 3600
date +%T;
echo "turning on fan.int.1"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 11
sleep 3600

date +%T;
echo "turning off fan.int.2"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 20
sleep 3600
date +%T;
echo "turning on fan.int.2"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 21
sleep 3600

date +%T;
echo "turning off fan.int.3"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 30
sleep 3600
date +%T;
echo "turning on fan.int.3"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 31
sleep 3600

date +%T;
echo "turning off fan.int.4"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 40
sleep 3600
date +%T;
echo "turning on fan.int.4"
adb -s 10.1.3.91:5555 shell /cache/fancontrol.sh 41


