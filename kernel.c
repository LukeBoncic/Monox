#include <stdint.h>

#include "debug.h"
#include "trap.h"
#include "print.h"

void main(void)
{
	init_idt();
	char *string = "Monox OS";
	int64_t value = 0x123456789ABCDEF;
	print("%s\n", string);
	print("This value is equal to %x", value);
}
