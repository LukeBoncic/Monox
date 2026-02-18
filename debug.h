#ifndef DEBUG_H
#define DEBUG_H

#include <stdint.h>

#include "print.h"

#define DEBUG

#ifndef DEBUG
#define assert(e)
#else
#define assert(e) { if (!(e)) print("\n\nAssertion Failed [ File %s: Line %u ]", __FILE__, __LINE__); while (1); }
#endif

#endif

