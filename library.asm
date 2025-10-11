section .text

global memset
global memcpy
global memcmp

memset:
	cld
	mov ecx, edx
	mov al, sil
	rep stosb
	ret

memcpy:
	std
	dec rsi
	dec rdi
	mov ecx, edx
	rep movsb
	cld
	ret
memcmp:
	cld
	mov eax, 0
	mov ecx, edx
	repe cmpsb
	setz al
	ret
