flat := -flat_namespace -undefined suppress
twolevel := -Wl,-no_fixup_chains -undefined dynamic_lookup

NAMESPACE ?= two-level
ifeq ($(NAMESPACE),flat)
NAMESPACE_OPTS := $(flat)
else
NAMESPACE_OPTS := $(twolevel)
endif

.PHONY: all clean

all: main main_shared extension.dylib dependent.dylib

main_shared: main.c libmain.dylib libfoo1.dylib
	$(CC) -o $@ -DENABLE_SHARED=1 main.c -L. -lmain -lfoo1

main: main.c libfoo1.dylib
	$(CC) -o $@ main.c -L. -lfoo1

libmain.dylib: main.c libfoo1.dylib
	$(CC) -dynamiclib -DLIBMAIN=1 -o $@ main.c -L. -lfoo1

libfoo1.dylib: foo.c
	$(CC) -dynamiclib -DFOO_VERSION=1 -o $@ $<

extension.dylib: extension.c libfoo2.a
	$(CC) -o $@ -dynamiclib $(NAMESPACE_OPTS) extension.c libfoo2.a

dependent.dylib: dependent.c extension.dylib
	$(CC) -o $@ -dynamiclib $(NAMESPACE_OPTS) dependent.c extension.dylib

foo2.o: foo.c
	$(CC) -c -o $@ -DFOO_VERSION=2 $^

libfoo2.a: foo2.o
	$(RM) $@
	ar -cr $@ $^

clean:
	$(RM) main main_shared *.dylib *.dylib *.o *.a
