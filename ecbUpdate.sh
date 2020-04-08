#!/bin/sh
# For update 8ui ECB aprom and/or envtable
# By John.xu
# need: nuvoisp, pl2303_example

# Usage example:
# 1) sudo ./SampleForUpdateFirmware.sh "-f /data/aprom-000006.bin -t /data/ecbtable.bin"
# 2) sudo ./SampleForUpdateFirmware.sh "-f /data/aprom-000006.bin"
# 3) sudo ./SampleForUpdateFirmware.sh "-t /data/ecbtable.bin"

# stop envctl.service
sudo systemctl stop envctl.service 
sleep 2
#########################################################
# here, it is in APROM
#########################################################

# read the version before updating
sudo ./nuvoisp -a "AA40 00 00 00 00 00"
# hold 24V on
sudo ./pl2303_example -o 0 1 
sleep 2
# sent update firmware command
sudo ./nuvoisp -a "AA41 00 00 00 00 00"

# wait LDROM boot
sleep 2

#########################################################
# here, it is in LDROM
#########################################################

# do update
echo $1
sudo ./nuvoisp $1

sleep 2
# remove 24v holding, only when it went back to aprom
# sudo ./pl2303_example -o 0 0
sudo systemctl start envctl.service
