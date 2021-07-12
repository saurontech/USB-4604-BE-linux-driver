obj-m := adv_usb_serial.o
adv_usb_serial-objs := xr_usb_serial_common.o

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD       := $(shell pwd)

EXTRA_CFLAGS	:= -DDEBUG=0

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD)

modules_install:
	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules_install

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions vtty *.symvers *.order *.a *.mod
