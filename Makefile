DISK = os.img
KERNEL = kernel
BOOTSECTOR = bootsector

ELF = kernel.elf library.elf trap.elf
OBJ = kernel.o print.o trap.o

DEPEND = debug.h library.h print.h trap.h

CC = gcc
ASM = nasm
LD = ld

OBJCOPY = objcopy

QEMU = qemu-system-x86_64

run: $(DISK)
	$(QEMU) -drive file=$(DISK),format=raw

clean:
	rm $(DISK) $(KERNEL) $(BOOTSECTOR) *.o *.elf *.bin

$(DISK): $(KERNEL) $(BOOTSECTOR)
	dd if=$(BOOTSECTOR) of=$(DISK) bs=512 count=1 conv=notrunc
	dd if=$(KERNEL) of=$(DISK) bs=512 seek=1 conv=notrunc
	dd if=/dev/zero of=$(DISK) bs=512 seek=20479 count=1

$(BOOTSECTOR): boot.asm
	$(ASM) -f bin -o $(BOOTSECTOR) boot.asm

$(KERNEL): $(ELF) $(OBJ)
	$(LD) -nostdlib -T kernel.lds -o kernel.bin $(ELF) $(OBJ)
	$(OBJCOPY) -O binary kernel.bin $(KERNEL)

%.elf: %.asm
	$(ASM) -f elf64 -o $@ $<

%.o: %.c $(DEPEND)
	$(CC) -std=c99 -mcmodel=large -ffreestanding -fno-stack-protector -mno-red-zone -c -o $@ $<
