#include <stdio.h>

#ifndef FOO_VERSION
#define FOO_VERSION 1
#endif

void foo_version(void) {
    printf("foo_version(): %d\n", FOO_VERSION);
}
