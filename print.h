#ifndef PRINT_H
#define PRINT_H

#define LINE_SIZE 160

struct ScreenBuffer {
	char *buffer;
	int column;
	int row;
};

int print(const char *format, ...);

#endif
