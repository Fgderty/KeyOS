[bits 16]

;======================================================
;CONSTANTS(Prepocessor Directives)
;======================================================
%define CODE_SEG	0x08
%define DATA_SEG	0x10
%define A20_PORT	0x92
%define CR0_PE_BIT	0x01

;======================================================
;EXPORTS & IMPORTS
;======================================================
global _start
extern kernel_entry

section .text

;======================================================
;ENTRY POINT
;======================================================
_start:
	xor ax, ax
	mov ds, ax,
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00

	mov si, msg_rm
	call print_rm

	jmp enter_pm

print_rm:
	lodsb
	cmp al, 0
	je .done
	mov ah, 0x0E
	int 0x10
	jmp print_rm
.done:
	ret

enter_pm:
    cli
    lgdt[gdt_descriptor]

    in al, A20_PORT
    or al, 0x02
    out A20_PORT, al

    mov eax, cr0
    or eax, CR0_PE_BIT
    mov cr0, eax

	jmp 0x08:kernel_entry

;======================================================
;DATA & GT
;======================================================
section .rodata
msg_rm db "Bootloader: Entering Protected Mode...", 0x0D, 0x0A, 0x00

align 8
gdt_start:
	dq 0x00
gdt_code:
	dw 0xFFFF
	dw 0x00
	db 0x00
	db 10011010b
	db 11001111b
	db 0x00
gdt_data:
	dw 0xFFFF
	dw 0x00
	db 0x00
	db 10010010b
	db 11001111b
	db 0x00
gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start
