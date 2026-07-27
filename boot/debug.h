#ifndef _DEBUG_H_
#define _DEBUG_H_

#include <stdint.h>

// This macro is used to check if a certain expression which should be true is actually false for
// debugging purposes, and if it is false it will call error_check() which will stop the program
#define ASSERT(e) if (!(e)) error_check(__FILE__,__LINE__) 

void error_check(char *file, int line);

#endif
