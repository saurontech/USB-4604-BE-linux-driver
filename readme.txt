============================================================================
	       	Advantech Linux USB Serial driver for USB-4604B(M)-BE
		         Installation Guide
============================================================================

This README file describes the HOW-TO of driver installation.

1. Introduction

   This driver will work with any USB UART function in these devices:
   USB-4604B-BE(RS-232 only)
   USB-4604BM-BE(RS-232/RS-422/RS-485)

   This driver support Linux Kernel 3.6.x and newer.
   

2. Compile the driver

   2.1 Dependancy
	You should install the kernel header files to compile this driver.

   2.1.1 Ubuntu
	# sudo apt-get install build-essential linux-headers-generic

   2.1.2 OpenSUSE
	Open YaST / Software / Software Management.
	Select the View Button on the top left and pick Patterns. 
	Now, you will see several Patterns listed and you want to select:
	Development 
	[X] Base Development
	[X] Linux Kernel Development
	[X] C/C++ Development

   2.1.3 CentOS/RHEL/Fedora
	# yum install kernel-devel kernel-headers gcc make
	
   2.2 Compile the source code
	This driver comes with a Makefile, therefore you can compile the driver with a single command.
	# make
	
	
3. Installation

   3.1 Install the common usb serial driver module
	# insmod ./adv_usb_serial.ko

   3.2 Plug the device into the USB host.  You should see up to four devices created,
	typically /dev/ttyADVUSB[0-3].

   3.3 Use procfs to set operation mode
	If you are using USB-4604BM-BE, you can set operation mode RS-232/RS-422/RS-485 to your serial port with this command
	# echo [232/422/485] > /proc/driver/adv-usb-serial[minor]
	the [minor] is the minor number of serial port

	For example:
	# echo 485 > /proc/driver/adv-usb-serial0

	You can also get operation mode from procfs:
	# cat /proc/driver/adv-usb-serial[minor]

   3.4 Open serial port


4. Tips for Debugging

   4.1 Check that the USB UART is detected by the system
	# lsusb
	Bus 007 Device 002: ID 1809:b704 Advantech --> b604/b704 is the ID of USB-4604-B/USB-4604-BM

   4.2 Check that the CDC-ACM driver was not installed for the USB-4604B(M)
	# ls /dev/tty*

	To remove the CDC-ACM driver and install the driver:
	# rmmod cdc-acm
	# modprobe -r usbserial
	# modprobe usbserial
	# insmod ./adv_usb_serial.ko

