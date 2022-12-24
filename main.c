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
    int ret = 1;
    void *handle = 0;
    void *dependent_handle = 0;
    handle = dlopen("extension.dylib", RTLD_LAZY | RTLD_GLOBAL);
    if (!handle) {
        fprintf(stderr, "dlopen(\"extension.dylib\"): %s\n", dlerror());
        goto err;
    }

    dependent_handle = dlopen("dependent.dylib", RTLD_LAZY | RTLD_GLOBAL);
    if (!dependent_handle) {
        fprintf(stderr, "dlopen(\"dependent.dylib\"): %s\n", dlerror());
        goto err;
    }

    void (*extension_init)(void) = dlsym(handle, "init");
    if (!extension_init) {
        fprintf(stderr, "dlsym(handle, \"init\"): %s\n", dlerror());
        goto err;
    }
    void (*dependent_init)(void) = dlsym(dependent_handle, "init_dependent");
    if (!dependent_init) {
        fprintf(stderr, "dlsym(dependent_handle, \"init_dependent\"): %s\n", dlerror());
        goto err;
    }

    foo_version();
    extension_init();
    dependent_init();
    ret = 0;
err:
    if (dependent_handle)
        dlclose(dependent_handle);
    if (handle)
        dlclose(handle);
    return ret;
}
#else
int main_implementation(void);
#endif

#if !LIBMAIN
int main() {
    return main_implementation();
}
#endif
