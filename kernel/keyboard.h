#ifndef _KEYBOARD_H_
#define _KEYBOARD_H_

#include "stdint.h"

struct KeyboardBuffer {
	char buffer[4096];
	int front;
	int end;
	int size;
};

#define E0_SIGN (1 << 0)
#define SHIFT (1 << 1)
#define CAPS_LOCK (1 << 2)

char read_key_buffer(void);
void keyboard_handler(void);
void move_cursor(int row, int column);

void outb(uint16_t port, uint8_t byte);
uint8_t inb(uint16_t port);

#endif
