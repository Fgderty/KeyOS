#ifndef IO_H
#define IO_H

#include <stdint.h>

extern void geass_outb(uint16_t port, uint8_t value);
extern uint8_t sharingan_inb(uint16_t port);

#endif