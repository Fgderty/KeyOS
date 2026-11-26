#include "pic.h"
#include "io.h"

#define PIC1_COMMAND    0x20
#define PIC1_DATA       0x21
#define PIC2_COMMAND    0xA0
#define PIC2_DATA       0xA1

#define ICW1_INIT       0x11
#define ICW4_8086       0x01

#define PIC1_OFFSET     0x20
#define PIC2_OFFSET     0x28

static void io_wait(){
    geass_outb(0x80, 0);
}

void pic_remap(){
    geass_outb(PIC1_COMMAND, ICW1_INIT);io_wait();
    geass_outb(PIC2_COMMAND, ICW1_INIT);io_wait();

    geass_outb(PIC1_DATA, PIC1_OFFSET);io_wait();
    geass_outb(PIC2_DATA, PIC2_OFFSET);io_wait();

    geass_outb(PIC1_DATA, 0x04);io_wait();
    geass_outb(PIC2_DATA, 0x02);io_wait();

    geass_outb(PIC1_DATA, ICW4_8086);io_wait();
    geass_outb(PIC2_DATA, ICW4_8086);io_wait();

    geass_outb(PIC1_DATA, 0xFF);io_wait();
    geass_outb(PIC2_DATA, 0xFF);io_wait();
}