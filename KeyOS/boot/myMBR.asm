[bits 16]
[org 0x7c00]

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

    in al, 0x92
    or al, 0x02
    out 0x92, al

    mov eax, cr0
    or eax, 0x01
    mov cr0, eax

	jmp 0x08:init_pm

msg_rm db "Hello from 16-bit Real Mode!", 13, 10, 0

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



[bits 32]

init_pm:
	mov ax, 0x10
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov edi, 0xB8000
	mov ecx, 2000
	mov ax, 0x0F20
	rep stosw

	mov esp, 0x90000

	mov edx, 0xB8000 + 160
	mov ebx, msg_pm
	
.loop_pm:
	mov al, [ebx]
	cmp al, 0x00
	je .done_pm
	mov ah, 0x0F
	mov [edx], ax
	add ebx, 0x01
	add edx, 0x02
	jmp .loop_pm
.done_pm:
	jmp $

msg_pm db "Success! KeyOS is entering 32-bit Protected Mode.", 0

times 510-($-$$) db 0
dw 0xAA55
