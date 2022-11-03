#!/bin/bash

if [ `id -u` -ne 0 ]; then
	dialog --title "D3 Edge AI Fusion Setup" \
        --msgbox "For this script to work properly, please run as root." 0 0
	clear
	exit 1;
fi

TEMP_FILENAME="./temp.txt"
GH_BASE_URL="https://github.com/D3Engineering"
FUSION_ROSPKG_URL="${GH_BASE_URL}/edge-ai-ros-fusion"
GAMEPAD_ROSPKG_URL="${GH_BASE_URL}/edge-ai-ros-gamepad"
MOTORCTL_ROSPKG_URL="${GH_BASE_URL}/edge-ai-ros-motorctl"
ROS_DRIVERS_DIR="/opt/robotics_sdk/ros1/drivers"
UDEV_RULES_DIR="/etc/udev/rules.d"
USR_BIN_DIR="/usr/local/bin"

function prepare_fd() {
	rm -f $TEMP_FILENAME
	exec 3<> $TEMP_FILENAME
}

function get_dialog_result() {
	exec 3>&-
	cat $TEMP_FILENAME
}

function empty_check() {
	if [ -z $1 ]; then
		clear
		exit 1;
	fi
}

prepare_fd

dialog --title "D3 Edge AI Fusion Setup" \
--output-separator "[+]" \
--checklist "Select components to install:" 0 0 5 \
 1 "Camera/Radar Fusion ROS Package" on \
 2 "Radar Loading udev Rule" on \
 3 "Gamepad ROS Package" off \
 4 "TI Spins Motors ROS Package" off --output-fd 3

COMPONENTS=`get_dialog_result`
prepare_fd
empty_check $COMPONENTS

dialog --title "D3 Edge AI Fusion Setup" \
--output-separator "[+]" \
--radiolist "Select Edge AI SDK Version" 0 0 0 \
 1 "08.04.00" on \
 2 "Other (untested)" off \
 --output-fd 3

VERSION=`get_dialog_result`
empty_check $VERSION
VERSION_TAG=""

case $VERSION in
	"[+]1")
		VERSION_TAG="08.04.00"
		;;
	*)
		VERSION_TAG="latest"
		;;
esac

echo "Components: $COMPONENTS"
echo "Version: $VERSION"
echo "Version Tag: $VERSION_TAG"

GIT_VERSION_INSERT=""
if [[ $VERSION_TAG != "latest" ]]; then
	GIT_VERSION_INSERT="-b $VERSION_TAG"
fi

if [[ $VERSION =~ "[+]2" ]]; then
	dialog --title "D3 Edge AI Fusion Setup" \
	--msgbox "Warning: Unsupported Version Selected, using latest version available. If you encounter issues, contact D3 for assistance." 0 0
fi

clear

if [[ $COMPONENTS =~ "[+]1" ]]; then
	git clone $GIT_VERSION_INSERT $FUSION_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_fusion
fi
if [[ $COMPONENTS =~ "[+]2" ]]; then
	cp 10-generic-radar.rules $UDEV_RULES_DIR
	mkdir $USR_BIN_DIR
	cp radar_load.sh $USR_BIN_DIR
fi
if [[ $COMPONENTS =~ "[+]3" ]]; then
	git clone $GIT_VERSION_INSERT $GAMEPAD_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_gamepad
fi
if [[ $COMPONENTS =~ "[+]4" ]]; then
	git clone $GIT_VERSION_INSERT $MOTORCTL_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_motorctl
fi

dialog --title "D3 Edge AI Fusion Setup" \
        --msgbox "Installation Complete! Please reboot your Edge AI for all changes to take effect." 0 0

clear
rm $TEMP_FILENAME
