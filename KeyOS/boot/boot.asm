[bits 16]

;======================================================
;CONSTANTS(Prepocessor Directives)
;======================================================
%define CODE_SEG		0x08
%define DATA_SEG		0x10

%define A20_PORT		0x92
%define CR0_PE_BIT		0x01

%define BIOS_VIDEO_INT	0x10
%define BIOS_VIDEO_TTY	0x0E

%define BIOS_DISK_INT	0x13
%define BIOS_DISK_READ	0x02

%define KERNEL_SEG		0x0000
%define KERNEL_OFFSET	0x1000
%define KERNEL_SECTORS	0x30
%define KERNEL_START	0x02

;======================================================
;EXPORTS & IMPORTS
;======================================================
global _start
global load_kernel

section .text

;======================================================
;ENTRY POINT
;======================================================
_start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0x7c00

	mov [boot_drive], dl

	call load_kernel

	jmp enter_pm
	
;======================================================
;LOAD KERNEL FUNCTION
;======================================================
load_kernel:
	mov ax, KERNEL_SEG
	mov es, ax
	mov bx, KERNEL_OFFSET

	mov ah, BIOS_DISK_READ
	mov al, KERNEL_SECTORS
	xor ch, ch
	mov cl, KERNEL_START
	xor dh, dh
	mov dl, [boot_drive]

	int BIOS_DISK_INT
	jc .error
	ret

.error:
	mov ah, BIOS_VIDEO_TTY
	mov al, 'E'
	int BIOS_VIDEO_INT
	jmp $ 

;======================================================
;PROTECTED MODE SETUP
;======================================================
enter_pm:
    cli
    lgdt[gdt_descriptor]

    in al, A20_PORT
    or al, 0x02
    out A20_PORT, al

    mov eax, cr0
    or eax, CR0_PE_BIT
    mov cr0, eax

	jmp 0x08:KERNEL_OFFSET

;======================================================
;GDT(Global Descriptor Table)
;======================================================
section .data

align 8

boot_drive db 0x00

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
