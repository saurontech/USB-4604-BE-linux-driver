MODNAME = adv_usb_serial
VERSION = 1.0

all: build_driver

build_driver:
	make -C ./driver

install_dkms: 
	make -C ./driver clean
	dkms add ./driver
	dkms build -m $(MODNAME) -v $(VERSION)
	dkms install -m $(MODNAME) -v $(VERSION)

uninstall_dkms:
	dkms uninstall -m $(MODNAME) -v $(VERSION)
	dkms remove -m $(MODNAME) -v $(VERSION) --all

clean:
	make clean -C ./driver
