DISK = os.img
KERNEL = kernel
LOADER = loader.bin
BOOTSECTOR = boot.bin

ELF = kernel.a library.a trap.a
OBJ = kernel.o memory.o print.o trap.o

DEPEND = debug.h library.h memory.h print.h trap.h

CC = gcc
ASM = nasm
LD = ld

OBJCOPY = objcopy

BOCHS = bochs

run: $(DISK)
	$(BOCHS)

clean:
	rm $(DISK) $(KERNEL) *.o *.a *.bin *.elf

$(DISK): $(KERNEL) $(BOOTSECTOR) $(LOADER)
	dd if=$(BOOTSECTOR) of=$(DISK) bs=512 count=1 conv=notrunc
	dd if=$(LOADER) of=$(DISK) bs=512 seek=1 count=7 conv=notrunc
	dd if=$(KERNEL) of=$(DISK) bs=512 seek=8 count=24 conv=notrunc
	dd if=/dev/zero of=$(DISK) bs=512 seek=20479 count=1

$(KERNEL): $(ELF) $(OBJ)
	$(LD) -nostdlib -T kernel.lds -o kernel.elf $(ELF) $(OBJ)
	$(OBJCOPY) -O binary kernel.elf $(KERNEL)

%.bin: %.asm
	$(ASM) -f bin -o $@ $<

%.a: %.asm
	$(ASM) -f elf64 -o $@ $<

%.o: %.c $(DEPEND)
	$(CC) -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c -o $@ $<
