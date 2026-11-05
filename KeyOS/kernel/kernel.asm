[bits 32]

;======================================================
;CONSTANTS (Preprocessor Directive)
;======================================================

%define DATA_SEG		0x10
%define STACK_TOP		0x90000

%define VGA_MEMORY		0xB8000
%define SCREEN_COLS		0x50
%define SCREEN_ROWS		0x19
%define SCREEN_SIZE		(SCREEN_COLS * SCREEN_ROWS)

%define VGA_ATTR 		0x0F
%define SPACE_CHAR		0x20
%define VGA_CLEAR_WORD ((VGA_ATTR << 9) | SPACE_CHAR)

;======================================================
;EXPORTS
;======================================================
global kernel_entry

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

	mov edi, VGA_MEMORY
	mov ecx, SCREEN_SIZE
	mov ax, VGA_CLEAR_WORD
	rep stosw

	mov esp, STACK_TOP

	mov edx, VGA_MEMORY + (SCREEN_COLS * 2 * 2)
	mov ebx, msg_pm

.print_loop:
	mov al, [ebx]
	cmp al, 0x00
	je .done_pm
	mov ah, VGA_ATTR
	mov [edx], ax
	add ebx, 0x01
	add edx, 0x02
	jmp .print_loop
.done_pm:
	jmp $

;======================================================
;DATA
;======================================================
section .rodata
msg_pm db "Success! KeyOS is entering 32-bit Protected Mode.", 0x00
