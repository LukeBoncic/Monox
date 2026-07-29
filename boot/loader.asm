[BITS 16]
[ORG 0x7e00]

start:
	mov [drive_id], dl
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb error
	mov eax, 0x80000001
	cpuid
	test edx, (1<<29)
	jz error
	test edx, (1<<26)
	jz error
	mov ax, 0x2000
	mov es, ax

get_memory_info_start:
	mov eax, 0xe820
	mov edx, 0x534d4150
	mov ecx, 20
	mov dword [es:0], 0
	mov edi, 8
	xor ebx, ebx
	int 0x15
	jc error

get_memory_info:
	cmp dword [es:di+16], 1
	jne continue
	cmp dword [es:di+4], 0
	jne continue
	mov eax, [es:di]
	cmp eax, 0x30000000
	ja continue
	cmp dword [es:di+12], 0
	jne find
	add eax, [es:di+8]
	cmp eax,0x30000000 + 100*1024*1024
	jb continue
	
find:
	mov byte [load_image], 1

continue:
	add edi, 20
	inc dword [es:0]
	test ebx, ebx
	jz get_memory_done

	mov eax, 0xe820
	mov edx, 0x534d4150
	mov ecx, 20
	int 0x15
	jnc get_memory_info

get_memory_done:
	cmp byte [load_image], 1
	jne error

test_a20:
	mov ax, 0xffff
	mov es, ax
	mov word [0x7c00],0xa200
	cmp word [es:0x7c10],0xa200
	jne a20_line_set
	mov word[0x7c00],0xb200
	cmp word[es:0x7c10],0xb200
	je error
	
a20_line_set:
	xor ax, ax
	mov es, ax

set_video_mode:
	mov ax, 3
	int 0x10
	cli
	lgdt [gdt_32_pointer]
	mov eax, cr0
	or eax, 1
	mov cr0, eax

load_filesystem:
	mov ax, 0x10
	mov fs, ax
	mov eax, cr0
	and al, 0xfe
	mov cr0, eax

unreal_mode:
	sti
	mov cx, 203*16*63/100
	xor ebx, ebx
	mov edi, 0x30000000
	xor ax, ax
	mov fs, ax

read_fat:
	push ecx
	push ebx
	push edi
	push fs
	mov ax, 100
	call read_sectors
	test al, al
	jnz error

	pop fs
	pop edi
	pop ebx

	mov cx, 512*100/4
	mov esi, 0x60000
	
copy_data:
	mov eax, [fs:esi]
	mov [fs:edi], eax
	add esi, 4
	add edi, 4
	loop copy_data
	pop ecx
	add ebx, 100
	loop read_fat

read_remaining_sectors:
	push edi
	push fs
	mov ax, (203*16*63) % 100
	call read_sectors
	test al, al
	jnz error
	pop fs
	pop edi
	mov cx, (((203*16*63) % 100) * 512)/4
	mov esi, 0x60000

copy_remaining_data: 
	mov eax, [fs:esi]
	mov [fs:edi], eax
	add esi, 4
	add edi, 4
	loop copy_remaining_data
	cli
	lidt [idt_32_pointer]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp 08:protected_mode_entry

read_sectors:
	mov si, read_packet
	mov word[si], 0x10
	mov word[si+0x2], ax
	mov word[si+0x4], 0
	mov word[si+0x6], 0x6000
	mov dword[si+0x8], ebx
	mov dword[si+0xc], 0
	mov dl, [drive_id]
	mov ah, 0x42
	int 0x13 
	setc al
	ret

error:
	mov ah, 0x13
	mov al, 1
	mov bx, 0xa
	xor dx, dx
	mov bp, message
	mov cx, message_length 
	int 0x10

fail:
	jmp fail

[BITS 32]

protected_mode_entry:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov esp, 0x7c00
	cld
	mov edi, 0x70000
	xor eax, eax
	mov ecx, 0x10000/4
	rep stosd
	mov dword[0x70000], 0x71007
	mov dword[0x71000], 10000111b
	mov eax, (0xffff800000000000>>39)
	and eax, 0x1ff
	mov dword[0x70000+eax*8], 0x72003
	mov dword[0x72000], 10000011b
	lgdt [gdt_64_pointer]
	mov eax, cr4
	or eax, (1 << 5)
	mov cr4, eax
	mov eax, 0x70000
	mov cr3, eax
	mov ecx, 0xc0000080
	rdmsr
	or eax, (1 << 8)
	wrmsr
	mov eax, cr0
	or eax, (1<<31)
	mov cr0, eax
	jmp 08:long_mode_entry

[BITS 64]

long_mode_entry:
	mov rsp, 0x7c00
	cld
	mov rdi, 0x100000
	mov rsi, c_module
	mov rcx, 512*15/8
	rep movsq

	mov rax, 0xffff800000100000
	jmp rax

end:
	jmp end

message: db "Error with second stage bootloader"
message_length: equ $ - message

read_packet: times 16 db 0
drive_id: db 0 
load_image: db 0

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

idt_32_pointer:
	dw 0
	dd 0

gdt_64:
	dq 0
	dq 0x0020980000000000

gdt_64_length: equ $ - gdt_64

gdt_64_pointer:
	dw gdt_64_length - 1
	dd gdt_64

c_module:	
