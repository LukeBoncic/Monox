#include "print.h"
#include "file.h"
#include "debug.h"

void main(void)
{
	assert(load_file("KERNEL.BIN", 0x200000, file_globals) == 0);
	assert(load_file("SHELL.BIN", 0x30000, file_globals) == 0);
}
