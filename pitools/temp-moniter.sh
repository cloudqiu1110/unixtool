#!/bin/bash

function monitorTemp()
{
	cpuTemp0=$(cat /sys/class/thermal/thermal_zone0/temp)
	cpuTemp1=$(($cpuTemp0/1000))
	cpuTemp2=$(($cpuTemp0/100))
	cpuTempM=$(($cpuTemp2 % $cpuTemp1))
	
	echo CPU temp"="$cpuTemp1"."$cpuTempM"'C"
	echo GPU $(/opt/vc/bin/vcgencmd measure_temp)
	
	if [ $cpuTemp1 -gt 55 ]; then
		echo "danger danger danger danger  danger    danger   danger   danger "
		echo `date` >> /home/pi/tempo.log
		echo "CPU temp higher than 55 *C, automatically shutdown" >> /home/pi/tempo.log
		init 0
	fi
}

echo "This script needs sudo privilege, so that it can shutdown pi if temperature is too high"


#if [ "$(id -u)" != "0" ]; then
#   echo "This script must be run as root" 1>&2
#   exit 1
#fi
#
#echo $(id -u)


if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo $EUID



while [ true ]; do 
	monitorTemp
	echo
	echo
	sleep 5
done
