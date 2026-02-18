section .data

gdt_64:
	dq 0
	dq 0x0020980000000000
	dq 0x0020f80000000000
	dq 0x0000f20000000000

tss_descriptor:
	dw tss_length - 1
	dw 0
	db 0
	db 0x89
	db 0
	db 0
	dq 0

gdt_64_length: equ $ - gdt_64

gdt_64_pointer:
	dw gdt_64_length - 1
	dq gdt_64

tss:
	dd 0
	dq 0xffff800000190000
	times 88 db 0
	dd tss_length

tss_length: equ $ - tss

section .text

bits 64

global start
extern main

start:
	mov rax, gdt_64_pointer
	lgdt [rax]

set_tss:
	mov rax, tss
	mov rdi, tss_descriptor
	mov [rdi+2], ax
	shr rax, 16
	mov [rdi+4], al
	shr rax, 8
	mov [rdi+7], al
	shr rax, 8
	mov [rdi+8], eax
	mov ax, 0x20
	ltr ax

init_pit:
	mov al, (1<<2)|(3<<4)
	out 0x43, al
	mov ax, 11931
	out 0x40, al
	mov al, ah
	out 0x40, al

init_pic:
	mov al, 0x11
	out 0x20, al
	out 0xa0, al
	mov al, 32
	out 0x21, al
	mov al, 40
	out 0xa1, al
	mov al, 4
	out 0x21, al
	mov al, 2
	out 0xa1, al
	mov al, 1
	out 0x21, al
	out 0xa1, al
	mov al, 11111110b
	out 0x21, al
	mov al, 11111111b
	out 0xa1, al
	mov rax, kernel_entry
	push 8
	push rax
	db 0x48
	retf

kernel_entry:
	mov rsp, 0xffff800000200000
	call main

end:
	hlt
	jmp end
