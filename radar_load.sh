#!/bin/bash 
if [ ! -e "/dev/ttyXRUSB0" ]; then 
  echo "XR USB Serial Driver Not Loaded... Loading Driver..."; 
  rmmod cdc-acm 
  modprobe -r usbserial 
  modprobe usbserial 
  insmod /opt/edge_ai_apps/xr_usb_serial_common.ko 
else  
  echo "XR USB Serial Driver already Loaded"; 
fi 
