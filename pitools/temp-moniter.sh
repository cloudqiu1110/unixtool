#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
else
   echo "The pi will power off if CPU temp > 60"
fi

echo $EUID

while [ true ]; do 
	echo

	cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
	cpuTemp1=$(($cpuTemp0/1000))
	cpuTemp2=$(($cpuTemp0/100))
	cpuTempM=$(($cpuTemp2 % $cpuTemp1))
	
	echo CPU temp"="$cpuTemp1"."$cpuTempM"'C"  -----------   GPU $(/opt/vc/bin/vcgencmd measure_temp)
	
	if [ $cpuTemp1 -gt 60 ]; then
		echo "danger danger danger danger  danger    danger   danger   danger "
		echo `date` >> /home/pi/tempo.log
		echo "CPU temp higher than 60 *C, automatically shutdown" >> /home/pi/temperature.log
		init 0
	fi

	sleep 5
done

