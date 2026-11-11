[bits 32]

;======================================================
;CONSTANTS (Preprocessor Directive)
;======================================================
%define DATA_SEG		0x10
%define STACK_TOP		0x90000

;======================================================
;EXPORTS
;======================================================
global kernel_entry
extern kernel_main

section .text

;======================================================
;KERNEL ENTRY POINT (32-bit)
;======================================================
kernel_entry:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov esp, STACK_TOP

	call kernel_main

.done_pm:
	jmp $
