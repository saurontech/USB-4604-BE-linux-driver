The udev system handles the uevents on the Linux system. 
If used correctly with the device driver, one can setup a more harmonious and effective OS platform.
This document shows a few examples on how one can:
   * Fix a static name on the device node of the USB-4604-BE.
   * Setup the serial mode automatically, when a USB-4604-BE device is plugged in.


1. Collecting information
	Before writing a udev.rule file, one must collect the information specific to your PC and your USB-4604-BE.
	Use the command udevadm, shown as below(in this example to collect information related to /dev/ttyADVUSB0) 

		udevadm info -a -p  $(udevadm info -q path -n /dev/ttyADVUSB0)

	The output should look like:

		devadm info starts with the device specified by the devpath and then
		walks up the chain of parent devices. It prints for every device
		found, all possible attributes in the udev rules key format.
		A rule to match, can be composed by the attributes of the device
		and the attributes from one single parent device.

		  looking at device '/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.0/tty/ttyADVUSB0':
		    KERNEL=="ttyADVUSB0"
		    SUBSYSTEM=="tty"
		    DRIVER==""

		  looking at parent device '/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1/2-1.1:1.0':
		    KERNELS=="2-1.1:1.0"
		    SUBSYSTEMS=="usb"
		    DRIVERS=="cdc_xr_usb_serial"
		    ATTRS{bInterfaceClass}=="02"
		    ATTRS{iad_bFunctionClass}=="02"
		    ATTRS{supports_autosuspend}=="1"
		    ATTRS{bInterfaceProtocol}=="01"
		    ATTRS{iad_bFunctionProtocol}=="01"
		    ATTRS{bInterfaceSubClass}=="02"
		    ATTRS{iad_bFirstInterface}=="00"
		    ATTRS{bAlternateSetting}==" 0"
		    ATTRS{authorized}=="1"
		    ATTRS{iad_bInterfaceCount}=="02"
		    ATTRS{iad_bFunctionSubClass}=="02"
		    ATTRS{bmCapabilities}=="6"
		    ATTRS{bInterfaceNumber}=="00"
		    ATTRS{bNumEndpoints}=="01"

		  looking at parent device '/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.1':
		    KERNELS=="2-1.1"
		    SUBSYSTEMS=="usb"
		    DRIVERS=="usb"
		    ATTRS{bConfigurationValue}=="1"
		    ATTRS{devpath}=="1.1"
		    ATTRS{version}==" 2.00"
		    ATTRS{bMaxPower}=="100mA"
		    ATTRS{removable}=="removable"
		    ATTRS{authorized}=="1"
		    ATTRS{configuration}==""
		    ATTRS{idVendor}=="1809"
		    ATTRS{bDeviceProtocol}=="01"
		    ATTRS{product}=="USB-B704BM-BE"
		    ATTRS{manufacturer}=="Advantech"
		    ATTRS{speed}=="12"
		    ATTRS{devnum}=="27"
		    ATTRS{busnum}=="2"
		    ATTRS{bMaxPacketSize0}=="64"
		    ATTRS{idProduct}=="b704"
		    ATTRS{bmAttributes}=="a0"
		    ATTRS{quirks}=="0x0"
		    ATTRS{bNumInterfaces}==" 8"
		    ATTRS{rx_lanes}=="1"
		    ATTRS{maxchild}=="0"
		    ATTRS{avoid_reset_quirk}=="0"
		    ATTRS{urbnum}=="33"
		    ATTRS{serial}=="A013452110"
		    ATTRS{tx_lanes}=="1"
		    ATTRS{ltm_capable}=="no"
		    ATTRS{bDeviceClass}=="ef"
		    ATTRS{bcdDevice}=="0002"
		    ATTRS{bNumConfigurations}=="1"
		    ATTRS{bDeviceSubClass}=="02"
		...

	following list shows the attributes that we are most interested in:
	1. KERNELS=="2-1.1:1.0"
	2. ATTRS{serial}=="A013452110"
	3. ATTRS{bInterfaceNumber}=="00"
	4. ATTRS{idVendor}=="1809"
	5. ATTRS{idProduct}=="b704"

	The KERNELS of the first parent can be used to define the USB socket on your PC, which is currently used to connect your USB-4604-BE. 
	We can use it to write rules that specifically apply to devices, which is connected to this given USB socket. 
	Please notice that this value will differ according to the layout of the USB system on your PC. 

	The ATTRS{serial} is the serial number that represents your specific USB-4604-BE device. 
	It will be unique on every device.
	We can use it to write rules that specifically apply to a given device.

	The ATTRS{bInterfaceNumber} represents the serial port index on the USB-4604-BE device.

	The ATTRS{idVendor} represents the vender ID of the device.

	The ATTRS{idProduct} represents the product ID of the device; USB-4604-BE and USB-4604BM will have different product IDs.

2. Writing a udev.rule
	We provide three examples for your reference:
	1. The '99-usb4604be-fixed-usbsocket.rule'
		This example shows how one can assign a fixed name ‘ttyFixed*’ to the devices, which are connected to a given USB socket on you PC.
		Please change the value of ‘KERNELS’ according to the udev info provided by command udevadm

	2. The '99-usb4604-fixed-serialnum.rule'
		This example shows how one can assign a fixed name to a spacific usb-4604-be device.
		This rule file defines a static name as ttyFA* for the USB-4604-BE device with the serial number: "A013452110"
		and the name ttyFB* to the device with serial number:"N126584772"
		Please adjust the serial numbers according to the output of the udevadm command.

	3. The '99-usb4604-fixed-serialnum-usbsocket.rule'
		This example combines the previous 2 examples and assign a fixed name only when a specific device is connected to a specific serial socket.
	
	4. The '99-usb4604be-fixed-serialnum-init-mode.rule'
		This example is an addition to '99-usb4604-fixed-serialnum.rule', initiating the serial mode(RS-232/422/485) accoding to ones desire.

	If one desires to write its own rule, it is very important to notice that a rule can only combine attributes of the child and one parent.
	If the attributs are spreaded over multiple parents, one must use ENV{} to create environment variables to combine multiple rules. 

   2.1 Combinding attributes across multiple partents with "ENV{}"
	As an example, the file "99-usb4604be-fixed-serialnum.rule" trys to combind the following attributs: 
		* ATTRS{idVendor}, ATTRS{idProduct}, and ATTRS{serial}: which are attributes of the second parent.
		* ATTRS{bInterfaceNumber}: which is a attribute of the first parent.

	This particular example recognizes the ATTRS{idVendor}, ATTRS{idProduct} and sets an ENV called USB_HUB_TYPE to a given string "1809:b704".
	Then, it combinds USB_HUB_TYPE with the recognition of the ATTRS{serial}, and sets up another ENV called USB_4604_TYPE, according to the serial number.
	Finally, based on the USB_4604_TYPE, and the ATTRS{bInterfaceNumber} we can setup a symbolic link with a fixed name.

   2.2 Setting up a symbolic link with "SYMLINK"
	The keyword SYMLINK is used to setup symbolic links in the /dev/ directory.
	 As an example the file "99-usb4604be-fixed-serialnum.rule" sets up simbolic links "/dev/ttyFA*" for the device with serial number A013452110,
	and simbloic links "/dev/ttyFB*" for another device with serial number N126584772.

   2.3 Running commands with "RUN"
	As an example, the file "99-usb4604be-fixed-serialnum-init-mode.rule" uses "RUN" to setup the default serial mode based on the serial number and port number of the device.
	It is essential to use /bin/sh to execute bash commands if the command depends on evironment variables like PATH ...etc.
	This particular example uses "RUN" to setup the serial mode(RS-232,422,485) automatically, based on the serial number of the device.

   2.4 Reference
	For furter information on how to write a udev rule, one can find more details in the following documents:
	* man 7 udev
	* http://www.reactivated.net/writing_udev_rules.html 

3. Applying the customized rule to UDEV

	copy the rule file to the /etc/udev/rules.d folder and reload the rules via the followin command:

		sudo udevadm control --reload-rules; sudo udevadm trigger
