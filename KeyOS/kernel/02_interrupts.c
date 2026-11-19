#include <stdint.h>
#include "idt.h"

struct registers{
	uint32_t ds;
	uint32_t edi, esi, ebp, esp, ebx, edx, ecx, eax;
	uint32_t int_no, err_code;
	uint32_t eip, cs, eflags, useresp, ss;
};

void isr_handler(struct registers *regs){
	volatile uint16_t *vga = (volatile uint16_t*)0xB8000;
	uint16_t err_attr = 0x4F;

    vga[0] = (err_attr << 8) | 'I';
	vga[1] = (err_attr << 8) | 'N';
	vga[2] = (err_attr << 8) | 'T';
	vga[3] = (err_attr << 8) | ':';
	vga[4] = (err_attr << 8) | ' ';

	uint32_t int_no = regs -> int_no;

	for (int i = 0; i < 2; ++i){
		uint8_t digit = (int_no >> (4 * (1 - i))) & 0x0F;
		char c;
		if(digit < 10) c = '0' + digit;
		else c = 'A' + (digit - 10);
		vga[5 + i] = (err_attr << 8) | c;
	}

    while(1){}
}