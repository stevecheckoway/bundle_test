#include <stdio.h>

void foo_version(void);

void init_dependent(void) {
    puts("init_dependent()");
    foo_version();
}

