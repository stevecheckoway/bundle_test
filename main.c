#if !ENABLE_SHARED || LIBMAIN

#include <dlfcn.h>
#include <stdio.h>

void foo_version(void);

void function_in_main(void) {
    puts("function_in_main()");
}

#if !LIBMAIN
static
#endif
int main_implementation() {
    // Load the library.
    void *handle = dlopen("extension.bundle", RTLD_LAZY | RTLD_GLOBAL);
    if (!handle) {
        fprintf(stderr, "dlopen(): %s", dlerror());
        return 1;
    }

    void (*fun)(void) = dlsym(handle, "init");

    if (!fun) {
        perror("dlsym(\"init\")");
        return 1;
    }

    foo_version();
    fun();

    dlclose(handle);
    return 0;
}
#else
int main_implementation(void);
#endif

int main() {
    return main_implementation();
}
