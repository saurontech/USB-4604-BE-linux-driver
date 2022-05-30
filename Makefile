include Config.mk
_build =
_install =
y_build=
y_install=
y_build = build_basic
y_install = install_daemon
y_uninstall =

$(DKMS)_install		 += install_dkms
$(DKMS)_uninstall	 += uninstall_dkms

ifneq ($(DKMS), y)
y_install += install_driver
endif

all: $(y_build)

build_basic:
	make -C ./driver

install_daemon:
	install -d $(INSTALL_PATH)
	cp ./script/usb4604b $(INSTALL_PATH)
	chmod 111 $(INSTALL_PATH)usb4604b
	ln -sf $(INSTALL_PATH)usb4604b /sbin/usb4604b

install_driver:
	cp ./driver/adv_usb_serial.ko $(INSTALL_PATH)

install: $(y_install)

uninstall: $(y_uninstall)
	rm -Rf $(INSTALL_PATH)
	rm -f /sbin/usb4604b

# use dkms
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
