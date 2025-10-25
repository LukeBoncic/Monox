[BITS 16]
[ORG 0x8000]

start:
	mov byte [drive_id], dl

load_kernel:
	mov si, read_packet
	mov word [si], 0x10
	mov word [si+2], 24
	mov word [si+4], 0
	mov word [si+6], 0x1000
	mov dword [si+8], 8
	mov dword [si+12], 0
	mov ah, 0x42
	int 0x13
	jc error

get_memory_map_info:
	mov eax, 0xe820
	mov edx, 0x534d4150
	mov ecx, 20
	mov dword [0x9000], 0
	mov edi, 0x9008
	mov ebx, 0
	int 0x15
	jc error

get_memory_map:
	add edi, 20
	inc dword [0x9000]
	test ebx, ebx
	jz set_protected_mode
	mov eax, 0xe820
	mov edx, 0x534d4150
	mov ecx, 20
	int 0x15
	jnc get_memory_map

set_protected_mode:
	cli
	lgdt [gdt_32_pointer]
	lidt [idt_32_pointer]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp 8:protected_mode_entry

error:
	mov ax, 0xb800
	mov si, 0
	mov di, 1
	mov es, ax
	mov byte [es:si], '!'
	mov byte [es:di], 0xf
	
loop:
	jmp loop

[BITS 32]

protected_mode_entry:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov esp, 0x7c00
	cld
	mov edi, 0x80000
	mov eax, 0
	mov ecx, 0x4000
	rep stosd
	mov dword [0x80000], 0x81007
	mov dword [0x81000], 135
	lgdt [gdt_64_pointer]
	mov eax, cr4
	or eax, 32
	mov cr4, eax
	mov eax, 0x80000
	mov cr3, eax
	mov ecx, 0xc0000080
	rdmsr
	or eax, 256
	wrmsr
	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax
	jmp 8:0x10000

gdt_32:
	dq 0

code_32:
	dw 0xffff
	dw 0
	db 0
	db 0x9a
	db 0xcf
	db 0

data_32:
	dw 0xffff
	dw 0
	db 0
	db 0x92
	db 0xcf
	db 0

gdt_32_length: equ $ - gdt_32

gdt_32_pointer:
	dw gdt_32_length - 1
	dd gdt_32

gdt_64:
	dq 0
	dq 0x0020980000000000

gdt_64_length: equ $ - gdt_64

gdt_64_pointer:
	dw gdt_64_length - 1
	dd gdt_64
	
idt_32_pointer:
	dw 0
	dd 0

idt_64_pointer:
	dw 0x0fff
	dq 0x8000

idt_64_entry:
	dw 0
	dw 0x8
	db 0
	db 0x8e
	dw 0
	dd 0
	dd 0

read_packet: times 16 db 0
drive_id: db 0
