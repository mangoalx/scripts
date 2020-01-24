#!/system/bin/sh
date +%T;
echo "turning off fan.int.0"
/cache/fancontrol.sh 00 
sleep 7200
date +%T;
echo "turning on fan.int.0"
/cache/fancontrol.sh 01 
sleep 3600

date +%T;
echo "turning off fan.int.1"
/cache/fancontrol.sh 10 
sleep 7200
date +%T;
echo "turning on fan.int.1"
/cache/fancontrol.sh 11 
sleep 3600

date +%T;
echo "turning off fan.int.2"
/cache/fancontrol.sh 20 
sleep 7200
date +%T;
echo "turning on fan.int.2"
/cache/fancontrol.sh 21 
sleep 3600

date +%T;
echo "turning off fan.int.3"
/cache/fancontrol.sh 30 
sleep 7200
date +%T;
echo "turning on fan.int.3"
/cache/fancontrol.sh 31 
sleep 3600

date +%T;
echo "turning off fan.int.4"
/cache/fancontrol.sh 40 
sleep 7200
date +%T;
echo "turning on fan.int.4"
/cache/fancontrol.sh 41 
sleep 3600

#date +%T;
#echo "turning off fan.int.5"
#/cache/fancontrol.sh 50 
#sleep 7200
#date +%T;
#echo "turning on fan.int.5"
#/cache/fancontrol.sh 51 
#sleep 3600

date +%T;
echo "turning off fan.ext"
/cache/fancontrol.sh e0 

