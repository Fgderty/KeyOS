#define VGA_MEMORY		0xB8000
#define VGA_ATTR 		0x0F
#define SCREEN_COLS		80
#define SCREEN_ROWS		25
#define SCREEN_SIZE		(SCREEN_ROWS * SCREEN_COLS)


void kernel_main(void){
	unsigned short *vga = (unsigned short*)VGA_MEMORY;
	for(int i = 0; i < SCREEN_SIZE; ++i){
		vga[i] = (VGA_ATTR << 8) | 0x20;
	}

	const char *msg = "SUCCESS: KeyOS C-Kernel is running!";
	int i = 0;
	int offset = 80;

	while(msg[i] != '\0'){
		vga[offset + i] = (VGA_ATTR << 8) | msg[i];
		++i;
	}

	while(1){}
}
