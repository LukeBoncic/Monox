#include "debug.h"
#include "memory.h"
#include "print.h"

static struct FreeMemoryRegion free_memory_region[50];

void init_memory(void) {
	int32_t count = *(int32_t*)0x9000;
	uint64_t total_memory = 0;
	struct E820 *memory_map = (struct E820*)0x9008;
	int free_region_count = 0;
	for (int32_t i = 0; i < count; i++) {
		if (memory_map[i].type == 1) {
			free_memory_region[free_region_count].address = memory_map[i].address;
			free_memory_region[free_region_count].length = memory_map[i].length;
			total_memory += memory_map[i].length;
			free_region_count++;
		}
		print("%x  %u KB  %u\n", memory_map[i].address, memory_map[i].length / 1024, (uint64_t)memory_map[i].type);
	}
	print("Total memory is %u MB\n", total_memory / 1048576);
}
