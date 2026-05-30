MONOX_IMG = monox.img

BOOT = boot/boot.bin
LOADER = boot/loader.bin
KERNEL = kernel/kernel.bin
USER1 = user1/user.bin
USER2 = user2/user.bin
USER3 = user3/user.bin
LIB = lib/lib.a

build: $(MONOX_IMG)

clean:
	find . -type f -name "*.a" -delete
	find . -type f -name "*.o" -delete
	find . -type f -name "*.bin" -delete
	find . -type f -name "*.elf" -delete
	find . -type f -name "*.img" -delete
	find . -type f -name "*.obj" -delete

$(MONOX_IMG): $(KERNEL) $(LIB) $(USER1) $(USER2) $(USER3) bootloader
	dd if=/dev/zero of=$(MONOX_IMG) bs=512 count=20480 conv=notrunc
	dd if=$(BOOT) of=$(MONOX_IMG) bs=512 count=1 conv=notrunc
	dd if=$(LOADER) of=$(MONOX_IMG) bs=512 count=5 seek=1 conv=notrunc
	dd if=$(KERNEL) of=$(MONOX_IMG) bs=512 count=100 seek=6 conv=notrunc
	dd if=$(USER1) of=$(MONOX_IMG) bs=512 count=10 seek=106 conv=notrunc
	dd if=$(USER2) of=$(MONOX_IMG) bs=512 count=10 seek=116 conv=notrunc
	dd if=$(USER3) of=$(MONOX_IMG) bs=512 count=10 seek=126 conv=notrunc

$(USER1):
	cd user1; make

$(USER2):
	cd user2; make

$(USER3):
	cd user3; make

$(LIB):
	cd lib; make

$(KERNEL): kernel
	cd kernel; make

bootloader: boot
	cd boot; make
