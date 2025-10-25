#include "memory.h"
#include "trap.h"

void main(void)
{
	init_idt();
	init_memory();
}
