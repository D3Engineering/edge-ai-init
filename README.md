D3 Radar/Camera Fusion for TI Edge AI
======

## Getting Started

You can get started with D3 Radar/Camera Fusion in three simple steps:
1. Run `git clone https://github.com/D3Engineering/edge-ai-init && cd edge-ai-init`
2.  Run `./init_setup.sh`
3.  Follow the prompts in the script to install the components you desire

## Assigning consistent device handles to Radars

Using udev rules, you can assign specific ports to come up with consistent device handles.

We have done this by looking at the KERNELS value of the device and populating the 10-radar.rules as follows:

1. Install the `10-generic-radar.rules` file to `/etc/udev/rules.d/` manually or using the 
`init_script.sh`
2. Run `udevadm control --reload-rules && udevadm trigger`
3. Connect a radar to one of the USB ports you would like to assign a handle to
4. Under `/dev/`, devices `ttyXRUSB0` and `ttyXRUSB1` should appear
5. For each device, run the command `udevadm info /dev/[device] --attribute-walk`
6. You should get a chain of devices output to your terminal. The first entry should begin with 
`looking at device`, the entry after that should have a `KERNELS` value, which allows us to identify 
the port the device is plugged into. Copy the whole line with the `KERNELS` value, and enter it into 
a new line in `/etc/udev/rules.d/10-radar.rules` as detailed below.
7. The `ttyXRUSB0` and `ttyXRUSB1` devices correspond to different interfaces to the Radar, 
and can be assigned separate handles as well. For example, the `KERNELS` value copied in the last 
step will end in either `:1.0` or `:1.2` - the `:1.0` device is the Radar Control interface, 
through which configuration commands are sent to the device, and the `:1.2` device is the Radar 
Data interface, through which raw data is sent from the device.

### udev Rule Format Template 
`[copied line], SUBSYSTEM=="tty", SYMLINK+="[yourdevicehandle]", RUN+="/usr/local/bin/radar_load.sh"`

### udev Rule Example

The rules below were used to consistently map the first port on our USB Hub to the Front-facing 
Radar Unit.
```
KERNELS=="1-1.1.1:1.0", SUBSYSTEM=="tty", SYMLINK+="frontradarcontrol", RUN+="/usr/local/bin/radar_load.sh"
KERNELS=="1-1.1.1:1.2", SUBSYSTEM=="tty", SYMLINK+="frontradardata", RUN+="/usr/local/bin/radar_load.sh"
```
