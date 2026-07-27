section .note.GNU-stack noalloc noexec nowrite progbits
section .text
extern main
global start

; Set the stack pointer to the kernel address, then we jump
; to the code written in C, when it returns, jump to kernel
start:
	mov rsp,0xffff800000200000
	call main

	mov rax,0xffff800000200000
	jmp rax

; Infinite loop if the kernel ever returns but it shouldn't.
end:
	jmp end