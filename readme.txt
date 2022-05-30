============================================================================
	       	Advantech Linux USB Serial driver for USB-4604B(M)-BE
		         Installation Guide
============================================================================

This README file describes the HOW-TO of driver installation.

1. Introduction

   This driver will work with any USB UART function in these devices:
   USB-4604B(RS-232 only)
   USB-4604BM(RS-232/RS-422/RS-485)

   This driver support Linux Kernel 3.6.x and newer.
   

2. Compile the driver

   2.1 Dependancy
	You should install the kernel header files to compile this driver.

   2.1.1 Ubuntu
	# sudo apt-get install build-essential linux-headers-generic
	# sudo apt-get install dkms

   2.1.2 OpenSUSE
	Open YaST / Software / Software Management.
	Select the View Button on the top left and pick Patterns. 
	Now, you will see several Patterns listed and you want to select:
	Development 
	[X] Base Development
	[X] Linux Kernel Development
	[X] C/C++ Development

	Utilize the Search Button to install the following packages:
	[X] dkms

   2.1.3 CentOS/RHEL/Fedora
	# dnf install kernel-devel kernel-headers gcc make
	# dnf install dkms

	* Early RedHat systems (before CentOS 7/RHEL 7/Fedora 21) might require you to use "yum" instead of "dnf".
	# yum install kernel-devel kernel-headers gcc make
	# yum install dkms
	
   2.2 Compile the source code
	This driver comes with a Makefile, therefore you can compile the driver with a single command.
	# make

   2.3 Installing the driver with or without DKMS
	By editing the "DKMS" option in the "Config.mk" file to "y" or "n", the drive will be installed("make install") with or without DKMS.
	
	
3. Installation

   3.1 Insert the USB-4604BM usb serial driver module
	 The CDC-ACM driver seems to wrongly adopt the USB-4604BM driver; 
	therefore, if CDC-ACM is not needed, one can simply remove the CDC_ACM driver.
	# rmmod cdc-acm

	Install the driver by using the following command
	# sudo modprobe adv_usb_serial

   		*if one didn't install this driver via DKMS, one can insert the ko file directly. 
		# insmod ./adv_usb_serial.ko

   3.2 Plug the device into the USB host.  You should see up to four devices created,
	typically /dev/ttyADVUSB[0-3].

   3.3 Use procfs to set operation mode
	If you are using USB-4604BM, you can set operation mode RS-232/RS-422/RS-485 to your serial port with this command
	# echo [232/422/485] > /proc/driver/adv-usb-serial[minor]
	the [minor] is the minor number of serial port

	For example:
	# echo 485 > /proc/driver/adv-usb-serial0

	You can also get operation mode from procfs:
	# cat /proc/driver/adv-usb-serial[minor]

4. Solving the conflict with the CDC-ACM driver
	  On some systems the USB-4604B(M) device might be bound to the default CDC-ACM driver, 
	this will previent it from being properly handled by our custom driver.
	  To solve this issue, you can chose on of the following methods, based on your need.

   4.1 Remove or reorder the CDC-ACM driver.
	# sudo rmmod cdc-acm 
	# sudo modprobe adv_usb_serial
	# sudo modprobe cdc-acm

   4.2 Manually unbinding and binding the device
	If the CDC-ACM driver is currently in use, one can unbind the device manually, and afterwards bind it to our driver.

      4.2.1 Reveal the usb node hierarchy
	# tree /sys/bus/usb/drivers/cdc_acm/
	/sys/bus/usb/drivers/cdc_acm/
	├── 2-1.1:1.0 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.0
	├── 2-1.1:1.1 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.1
	├── 2-1.1:1.2 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.2
	├── 2-1.1:1.3 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.3
	├── 2-1.1:1.4 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.4
	├── 2-1.1:1.5 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.5
	├── 2-1.1:1.6 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.6
	├── 2-1.1:1.7 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.7
	├── bind
	├── module -> ../../../../module/adv_usb_serial
	├── new_id
	├── remove_id
	├── uevent
	└── unbind

      4.2.2 Unbind the usb nodes from CDC-ACM

	Unbind the nodes from cdc_acm, the node number should be based on the info revealed from the "4.2.1 tree"command
	# sudo sh -c 'echo -n "2-1.1:1.0" > /sys/bus/usb/drivers/cdc_acm/unbind'
	# sudo sh -c 'echo -n "2-1.1:1.2" > /sys/bus/usb/drivers/cdc_acm/unbind'
	# sudo sh -c 'echo -n "2-1.1:1.4" > /sys/bus/usb/drivers/cdc_acm/unbind'
	# sudo sh -c 'echo -n "2-1.1:1.6" > /sys/bus/usb/drivers/cdc_acm/unbind'

      4.2.3 Bind the usb nodes to the USB4604 driver
	# sudo sh -c 'echo -n "2-1.1:1.0" > /sys/bus/usb/drivers/cdc_xr_usb_serial/bind'
	# sudo sh -c 'echo -n "2-1.1:1.2" > /sys/bus/usb/drivers/cdc_xr_usb_serial/bind'
	# sudo sh -c 'echo -n "2-1.1:1.4" > /sys/bus/usb/drivers/cdc_xr_usb_serial/bind'
	# sudo sh -c 'echo -n "2-1.1:1.6" > /sys/bus/usb/drivers/cdc_xr_usb_serial/bind'

      4.2.4 Check the binding of the USB4604 driver
	# tree /sys/bus/usb/drivers/cdc_xr_usb_serial/
	/sys/bus/usb/drivers/cdc_xr_usb_serial/
	├── 2-1.1:1.0 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.0
	├── 2-1.1:1.1 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.1
	├── 2-1.1:1.2 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.2
	├── 2-1.1:1.3 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.3
	├── 2-1.1:1.4 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.4
	├── 2-1.1:1.5 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.5
	├── 2-1.1:1.6 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.6
	├── 2-1.1:1.7 -> ../../../../devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.7
	├── bind
	├── module -> ../../../../module/adv_usb_serial
	├── new_id
	├── remove_id
	├── uevent
	└── unbind

5. Integration with UDEV system
   The udev service can be used to do many thinks, for example: 
	* Giving the device node a fixed name in /dev/ 
	* Setting up the serial mode(RS-232/422/485) when the device is plugged in.
	* ...etc

   We provide several udev.rule examples in the misc/udev directory
   Check the misc/udev/readme.txt for more information.

6. Tips for Debugging

   6.1 Check that the USB UART is detected by the system
	# lsusb
	Bus 007 Device 002: ID 1809:b704 Advantech --> b604/b704 is the ID of USB-4604-B/USB-4604-BM

7. Loading the driver at boottime
   On systems that are based on systemd, one can add "adv_usb_serial"(without the double commas) to the /etc/modules, /etc/modules.conf or create a new .conf file in /etc/modules-load.d/
   On other systems that don't have systemd, adding the "modprobe" or "insmod" command to the /etc/rc files might also work.

   7.1 Systemd
	We also provide a systemd service file, It can remove CDC-ACM, insert USB4604 driver, and reinsert CDC-ACM automatically.
	It is located at "misc/systemd/usb4604b.service"

      7.1.1 Install usb4604b.service
	# make install -C ./misc/systemd/

      7.1.2 Enabling usb4604b.service
	Enabling the service on systemd during bootup.
	# systemctl enable usb4604b.service

      7.1.3 Starting usb4604b.service
	This will start the service via systemd right away.
	# systemctl start usb4604b.service

