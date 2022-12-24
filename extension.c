#include <stdio.h>

void function_in_main(void);
void foo_version(void);

void init(void) {
    puts("init()");
    function_in_main();
    foo_version();
}
