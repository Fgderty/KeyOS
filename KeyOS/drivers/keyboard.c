#include "keyboard.h"
#include "../drivers/io.h"

#include <stdint.h>

static const char scancode_normal[128] = {
    0,  27, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\b',
    '\t', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', '\n',
    0,   'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', '`',
    0,  '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0,
    '*',  0,  ' ', 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,    0,  '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '0', '.',
    0,    0,   0,   0,   0
};

static const char scancode_shift[128] = {
    0,  27, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '\b',
    '\t', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', '\n',
    0,   'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"', '~',
    0,   '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0,
    '*',  0,  ' ', 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,    0,  '7', '8', '9', '-', '4', '5', '6', '+', '1', '2', '3', '0', '.',
    0,    0,   0,   0,   0
};

static uint8_t shift_pressed = 0;
static uint16_t cursor_pos = 80 * 6;

static void update_cursor(uint16_t pos){
    geass_outb(0x3D4, 0x0F);
    geass_outb(0x3D5, (uint8_t)(pos & 0xFF));

    geass_outb(0x3D4, 0x0E);
    geass_outb(0x3D5, (uint8_t)((pos >> 8) & 0xFF));
}

void keyboard_init(void){
    geass_outb(0x21, 0xFD);

    geass_outb(0x3D4, 0x0A);
    geass_outb(0x3D5, 0x0E);

    geass_outb(0x3D4, 0x0B);
    geass_outb(0x3D5, 0x0F);

    update_cursor(cursor_pos);

    asm volatile ("sti");
}

void keyboard_handler(void){
    uint8_t scancode = sharingan_inb(0x60);
    if(scancode == 0x2A || scancode == 0x36){
        shift_pressed = 1;
        return;
    }

    if(scancode == 0xAA || scancode == 0xB6){
        shift_pressed = 0;
        return;
    }

    if(((scancode & 0x80) != 0) || (scancode >= 128)) return;

    const char *table = shift_pressed ? scancode_shift : scancode_normal;

    char c = *(table + scancode);

    if(c == '\n'){
        cursor_pos = ((cursor_pos / 80) + 1) * 80;

        if(cursor_pos >= 2000) cursor_pos = 80 * 6;
        update_cursor(cursor_pos);
        return;
    }

    if(c == '\b'){
        if(cursor_pos > 80 * 6){
            --cursor_pos;
            *((volatile uint16_t *)0xB8000 + cursor_pos) = (((uint16_t)0x0F << 8) | ' ');
            update_cursor(cursor_pos);
        }
        return;
    }

    if(c == 0) return;

    if(cursor_pos < 2000){
        *((volatile uint16_t *)0xB8000 + cursor_pos) = ((uint16_t)0x0F << 8) | (uint8_t)c;
        ++cursor_pos;
        update_cursor(cursor_pos);
    }
}