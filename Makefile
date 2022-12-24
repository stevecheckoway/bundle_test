flat := -flat_namespace -undefined suppress
twolevel := -Wl,-no_fixup_chains -undefined dynamic_lookup
load_hidden := -load_hidden

NAMESPACE ?= two-level
ifeq ($(NAMESPACE),flat)
$(info ** flat)
NAMESPACE_OPTS := $(flat)
STATIC_LIB_FLAG :=
else ifeq ($(NAMESPACE),load-hidden)
$(info ** load-hidden)
NAMESPACE_OPTS := $(flat)
STATIC_LIB_FLAG := $(load_hidden)
else
$(info ** two-level)
NAMESPACE_OPTS := $(twolevel)
STATIC_LIB_FLAG :=
endif

.PHONY: all clean

all: main main_shared extension.bundle

main_shared: main.c libmain.dylib libfoo1.dylib
	$(CC) -o $@ -DENABLE_SHARED=1 main.c -L. -lmain -lfoo1

main: main.c libfoo1.dylib
	$(CC) -o $@ main.c -L. -lfoo1

libmain.dylib: main.c libfoo1.dylib
	$(CC) -dynamiclib -DLIBMAIN=1 -o $@ main.c -L. -lfoo1

libfoo1.dylib: foo.c
	$(CC) -dynamiclib -DFOO_VERSION=1 -o $@ $<

extension.bundle: extension.c libfoo2.a
	$(CC) -o $@ -bundle $(NAMESPACE_OPTS) extension.c $(STATIC_LIB_FLAG) libfoo2.a

foo2.o: foo.c
	$(CC) -c -o $@ -DFOO_VERSION=2 $^

libfoo2.a: foo2.o
	$(RM) $@
	ar -cr $@ $^

clean:
	$(RM) main main_shared *.bundle *.dylib *.o *.a
