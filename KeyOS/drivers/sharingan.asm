[bits 32]

global sharingan_inb

section .text

sharingan_inb:
	mov edx, [esp + 4]
	in al, dx
	movzx eax, al
	ret
