DISK = os.img
BOOTSECTOR = boot.bin

ASM = nasm

BOCHS = bochs

run: $(DISK)
	$(BOCHS)

clean:
	rm $(DISK) *.bin

$(DISK): $(KERNEL) $(BOOTSECTOR) $(LOADER)
	dd if=$(BOOTSECTOR) of=$(DISK) bs=512 count=1 conv=notrunc
	dd if=/dev/zero of=$(DISK) bs=512 seek=20479 count=1

%.bin: %.asm
	$(ASM) -f bin -o $@ $<
