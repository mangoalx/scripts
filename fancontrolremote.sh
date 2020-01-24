#date +%T;
#echo "turning off fan.int.0"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 00 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 00 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 00 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 00 
#do it twice to ensure it is succeed
#sleep 7000
#date +%T;
#echo "turning on fan.int.0"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 01 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 01 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 01 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 01 
#sleep 3400

#date +%T;
#echo "turning off fan.int.1"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 10 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 10 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 10 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 10 
#do it twice to ensure it is succeed
#sleep 7000
#date +%T;
#echo "turning on fan.int.1"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 11 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 11 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 11 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 11 
#sleep 3400

#date +%T;
#echo "turning off fan.int.2"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 20 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 20 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 20 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 20 
#sleep 7000
#date +%T;
#echo "turning on fan.int.2"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 21 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 21 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 21 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 21 
#sleep 3400

#date +%T;
#echo "turning off fan.int.3"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 30 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 30 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 30 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 30 
#sleep 7000
date +%T;
echo "turning on fan.int.3"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 31 
adb -s 10.1.1.169 shell /cache/fancontrol.sh 31 
sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 31 
adb -s 10.1.1.169 shell /cache/fancontrol.sh 31 
sleep 3400

date +%T;
echo "turning off fan.int.4"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 40 
adb -s 10.1.1.169 shell /cache/fancontrol.sh 40 
sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 40 
adb -s 10.1.1.169 shell /cache/fancontrol.sh 40 
sleep 7000
date +%T;
echo "turning on fan.int.4"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 41 
adb -s 10.1.1.169 shell /cache/fancontrol.sh 41 
sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 41 
adb -s 10.1.1.169 shell /cache/fancontrol.sh 41 
sleep 3400

#date +%T;
#echo "turning off fan.int.5"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 50 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 50 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 50 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 50 
#sleep 7000
#date +%T;
#echo "turning on fan.int.5"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 51 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 51 
#sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh 51 
#adb -s 10.1.1.169 shell /cache/fancontrol.sh 51 
#sleep 3400

date +%T;
echo "turning off fan.ext"
#adb -s 10.1.0.169 shell /cache/fancontrol.sh e0 
adb -s 10.1.1.169 shell /cache/fancontrol.sh e0 
sleep 200
#adb -s 10.1.0.169 shell /cache/fancontrol.sh e0 
adb -s 10.1.1.169 shell /cache/fancontrol.sh e0 

