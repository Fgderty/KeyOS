[bits 32]

global geass_outb

section .text

geass_outb:
	mov edx, [esp + 4]
	mov eax, [esp + 8]
	out dx, al
	ret
