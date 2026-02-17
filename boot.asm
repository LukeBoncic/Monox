[BITS 16]
{ORG 0x7c00]

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00

print_message:
	mov ah, 0x13
	mov al, 1
	mov bx, 0xa
	mov dx, 0
	mov bp, message
	mov cx, message_length

end:
	jmp end

message: db "Hello"
message_length: equ $ - message

signature:
	times (0x1be-($-$$)) db 0
	db 0x80
	db 0, 2, 0
	db 0xf0
	db 0xff, 0xff, 0xff
	dd 1
	times 48 db 0
	db 0x55
	db 0xaa
