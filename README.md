# Bundle test
This repo contains a test of a moderately complex interaction involving two-level namespace lookups of symbols from a loaded dynamic library.

## Two-level namespace

To build, run `make` on macOS.

Here's the situation.

We have a `main` executable (souce code in `main.c`). It uses `dlopen()` to load `extension.dylib` (source code in `extension.c`) and call the `init()` function defined therein. It behaves simularly with `dependent.dylib`.

`main` also dynamically links to `libfoo1.dylib` (source code in `foo.c`). After the extension is loaded, `main` calls `foo_version()`.

The extension's `init()` calls `function_in_main()` which is a function defined in `main` itself.

The extension links to a static library, `libfoo2.a` (source code in `foo.c`) and also calls `foo_version()`.

`dependent.dylib` links to `extension.dylib` so calling `foo_version()` in the dependent extension calls the correct symbol from `extension.dylib`.

This doesn't work with extensions built as bundles because you cannot link to a bundle.

All of these functions print their names when called.

This all works correctly.
```
$ ./main
foo_version(): 1
init()
function_in_main()
foo_version(): 2
init_dependent()
foo_version(): 2
```

We have a second executable, `main_shared`, which is identical to `main` in behavior except that all of the functionality, including `function_in_main()`, lives in `libmain.dylib`.

This works too.
```
$ ./main_shared
foo_version(): 1
init()
function_in_main()
foo_version(): 2
init_dependent()
foo_version(): 2
```

## Flat namespace

To build, first `make clean` and then `make NAMESPACE=flat`. This builds the extension with `-flat_namespace -undefined suppress` rather than `-undefined dynamic_lookup`.

Running this immediately runs into problems. Both `main` and `main_shared` print
```
foo_version(): 1
init()
function_in_main()
foo_version(): 1
```

Note that `foo_version()` from the extensions ended up resolving to the version of `foo_version()` from `libfoo1.dylib` and not the version in `extension.dylib` itself!
