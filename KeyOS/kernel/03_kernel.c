#include <stdint.h>
#include "idt.h"

#define VGA_MEMORY 0xB8000
#define SCREEN_COLS 80
#define SCREEN_ROWS 25
#define SCREEN_SIZE (SCREEN_ROWS * SCREEN_COLS)

#define COLOR_BLACK 		0x00
#define COLOR_DARK_RED 		0x04
#define COLOR_LIGHT_GRAY 	0x07
#define COLOR_LIGHT_CYAN 	0x0B
#define COLOR_LIGHT_RED 	0x0C
#define COLOR_WHITE 		0x0F
#define VGA_COLOR(bg, fg) 	(((bg) << 4) | (fg))

extern void idt_init(void);

void vga_clear(uint8_t attr) {
    volatile uint16_t *vga = (volatile uint16_t *)VGA_MEMORY;
    uint16_t blank = ((uint16_t)attr << 8) | 0x20;
    for (int i = 0; i < SCREEN_SIZE; ++i) {
        vga[i] = blank;
    }
}

void vga_print_at(const char *str, uint8_t row, uint8_t col, uint8_t attr) {
    volatile uint16_t *vga = (volatile uint16_t *)VGA_MEMORY;
    int offset = row * SCREEN_COLS + col;
    int i = 0;
    while (str[i] != '\0') {
        vga[offset + i] = ((uint16_t)attr << 8) | (uint8_t)str[i];
        ++i;
    }
}

void kernel_main(void) {
    idt_init();

    uint8_t default_attr = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_GRAY);
    uint8_t crimson_attr = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_RED);
    uint8_t cyan_attr = VGA_COLOR(COLOR_BLACK, COLOR_LIGHT_CYAN);
    uint8_t pink_attr = VGA_COLOR(COLOR_BLACK, COLOR_DARK_RED);

    vga_clear(default_attr);

    vga_print_at("[ KeyOS ]", 1, 2, crimson_attr);
    vga_print_at("32-bit Protected Mode Kernel Initialized", 1, 12, default_attr);

    vga_print_at("[ IDT ]", 2, 2, cyan_attr);
    vga_print_at("256 Interrupt Vectors & Exception Handlers Active", 2, 12, pink_attr);

    vga_print_at("[ STATUS ]", 3, 2, crimson_attr);
    vga_print_at("System Ready. Zero-Dependency Architecture", 3, 13, default_attr);

	__asm__ volatile ("int $0x03");

    while (1) {}
}
