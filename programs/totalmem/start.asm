section .note.GNU-stack noalloc noexec nowrite progbits
section .text
global start
extern main
extern exitu

start:
	call main
	call exitu
	jmp $
