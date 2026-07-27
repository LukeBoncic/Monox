; Master boot record is loaded at 0x7c00

[BITS 16]
[ORG 0x7c00]

; Reset segment registers that were set to unknown values by the BIOS
; and set the stack pointer to where the master boot record is loaded
start:
	xor ax, ax  
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00

; Test if the disk extension service is available
test_disk_extension:
	mov [drive_id], dl
	mov ah, 0x41
	mov bx, 0x55aa
	int 0x13
	jc error
	cmp bx, 0xaa55
	jne error

; Load the 15 reserved sectors from the boot drive into 0x7e00,
; then jump to that address and run the second stage bootloader
load_second_stage:
	mov si, read_packet
	mov word [si], 0x10
	mov word [si+2], 15
	mov word [si+4], 0x7e00
	mov word [si+6], 0
	mov dword [si+8], 1
	mov dword [si+-12], 0
	mov dl, [drive_id]
	mov ah,0x42
	int 0x13
	jc error
	mov dl, [drive_id]
	jmp 0x0000:0x7e00 

; If the disk read throws an error, we jump here
error:
	mov ah, 0x13
	mov al, 1
	mov bx, 0xa
	xor dx, dx
	mov bp, message
	mov cx, message_length
	int 0x10

; And enter an infinite loop
end:
	jmp end
	
drive_id: db 0
message: db "Could not load reserved sectors"
message_length: equ $ - message
read_packet: times 16 db 0

padding: times (0x1be - ($ - $$)) db 0

partition_table:
	db 80h
	db 1, 1, 0
	db 06h
	db 0fh, 03fh, 0cah
	dd 3fh
	dd 031f11h
	
	times (16*3) db 0

	db 0x55
	db 0xaa

	
