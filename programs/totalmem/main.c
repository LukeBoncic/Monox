#include "stdint.h"

int main(void)
{
	int total = get_total_memoryu();
	printf("Total memory is %d MB\n", (int64_t)total);
	
	return 0;
}

