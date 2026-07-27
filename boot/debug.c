#include "debug.h"
#include "print.h"

// This function is called when an assertion fails and
// shows the file and line that caused the failure

void error_check(char *file, int line)
{
	print("Assertion Failed [file %s: line %u]", file, line);
	while (1) { }
}
