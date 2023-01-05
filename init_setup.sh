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
INV_VIZ_ROSPKG_URL="${GH_BASE_URL}/edge-ai-ros-inventory-viz"
INV_CTL_ROSPKG_URL="${GH_BASE_URL}/edge-ai-ros-inventory-demo"
DLP_ROSPKG_URL="${GH_BASE_URL}/edge-ai-ros-dlp"
APRILTAG_ROSPKG_URL="${GH_BASE_URL}/edge-ai-ros-apriltag"
NAV_ROSPKG_URL="${GH_BASE_URL}/edge-ai-ros-2dnav"
RSDK_DIR="/opt/robotics_sdk"
ROS_DRIVERS_DIR="${RSDK_DIR}/ros1/drivers"
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
--radiolist "Select Robot Demo Version" 0 0 0 \
 1 "Electronica" off \
 2 "CES" on \
 3 "Latest" off \
 --output-fd 3

VERSION=`get_dialog_result`
empty_check $VERSION
VERSION_TAG=""

case $VERSION in
	"[+]1")
		VERSION_TAG="08.04.00"
		;;
  "[+]2")
    VERSION_TAG="CES"
    ;;
	*)
		VERSION_TAG="latest"
		;;
esac

if [[ $VERSION_TAG == "08.04.00" ]]; then
  prepare_fd

  dialog --title "D3 Edge AI Fusion Setup" \
  --output-separator "[+]" \
  --checklist "Select components to install:" 0 0 5 \
   0 "Camera/Radar Fusion ROS Package" on \
   1 "Radar Loading udev Rule" on \
   2 "Gamepad ROS Package" off \
   3 "TI Spins Motors ROS Package" off --output-fd 3

  COMPONENTS=`get_dialog_result`
  prepare_fd
  empty_check $COMPONENTS
else
  prepare_fd

  dialog --title "D3 Edge AI Fusion Setup" \
  --output-separator "[+]" \
  --checklist "Select components to install:" 0 0 5 \
   0 "Camera/Radar Fusion ROS Package" on \
   1 "Radar Loading udev Rule" on \
   2 "Gamepad ROS Package" off \
   3 "C2000 Teknic Motors ROS Package" off \
   4 "SCUTTLE Motors Library and ROS Package" on \
   5 "Inventory Demo Controller ROS Package" on \
   6 "Inventory Demo Visualizer ROS Package" off \
   7 "DLP ROS Package" on \
   8 "AprilTag Localization ROS Package" on \
   9 "2D Navigation (move_base) ROS Package" on --output-fd 3

  COMPONENTS=`get_dialog_result`
  prepare_fd
  empty_check $COMPONENTS
fi

echo "Version: $VERSION"
echo "Components: $COMPONENTS"
echo "Version Tag: $VERSION_TAG"

GIT_VERSION_INSERT=""
if [[ $VERSION_TAG != "latest" ]]; then
	GIT_VERSION_INSERT="-b $VERSION_TAG"
fi

clear

if [[ $COMPONENTS =~ "[+]0" ]]; then
	git clone $GIT_VERSION_INSERT $FUSION_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_fusion
fi
if [[ $COMPONENTS =~ "[+]1" ]]; then
	cp 10-generic-radar.rules $UDEV_RULES_DIR
	mkdir $USR_BIN_DIR
	cp radar_load.sh $USR_BIN_DIR
fi
if [[ $COMPONENTS =~ "[+]2" ]]; then
	git clone $GIT_VERSION_INSERT $GAMEPAD_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_gamepad
fi
if [[ $COMPONENTS =~ "[+]3" ]]; then
	git clone $GIT_VERSION_INSERT $MOTORCTL_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_motorctl
fi
if [[ $COMPONENTS =~ "[+]4" ]]; then
  git clone -b PSDK_8_2 https://github.com/ansarid/ddcontroller ${RSDK_DIR}/scuttlepy
  cd ${RSDK_DIR}/scuttlepy && python3 setup.py install
  git clone -b noetic https://github.com/scuttlerobot/scuttle_driver ${ROS_DRIVERS_DIR}/scuttle_driver
fi
if [[ $COMPONENTS =~ "[+]5" ]]; then
  git clone $GIT_VERSION_INSERT $INV_CTL_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_inventory_demo
fi
if [[ $COMPONENTS =~ "[+]6" ]]; then
  git clone $GIT_VERSION_INSERT $INV_VIZ_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_inventory_viz
fi
if [[ $COMPONENTS =~ "[+]7" ]]; then
  git clone $GIT_VERSION_INSERT $DLP_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_dlp
fi
if [[ $COMPONENTS =~ "[+]8" ]]; then
  git clone $GIT_VERSION_INSERT $APRILTAG_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_apriltag
fi
if [[ $COMPONENTS =~ "[+]9" ]]; then
  git clone $GIT_VERSION_INSERT $NAV_ROSPKG_URL ${ROS_DRIVERS_DIR}/d3_2dnav
fi

dialog --title "D3 Edge AI Fusion Setup" \
        --msgbox "Installation Complete! Please reboot your Edge AI for all changes to take effect." 0 0

clear
rm $TEMP_FILENAME
