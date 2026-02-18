[BITS 16]
[ORG 0x7c00]

start:
	mov ax, 0
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00
	mov byte [drive_id], dl

set_video_mode:
	mov ax, 3
	int 0x10

load_loader:
	mov si, read_packet
	mov word [si], 0x10
	mov word [si+2], 7
	mov word [si+4], 0x8000
	mov word [si+6], 0
	mov dword [si+8], 1
	mov dword [si+12], 0
	mov ah, 0x42
	int 0x13
	jnc 0x8000

error:
	mov ax, 0xb800
	mov si, 0
	mov di, 1
	mov es, ax
	mov byte [es:si], '!'
	mov byte [es:di], 0xf
	
loop:
	jmp loop

read_packet: times 16 db 0
drive_id: db 0

signature:
	times (0x1be-($-$$)) db 0
	db 0x80
	db 0, 2, 0
	db 0xf0
	db 0xff, 0xff, 0xff
	dd 1
	dd (20*16*63-1)
	times (16*3) db 0
	db 0x55
	db 0xaa
