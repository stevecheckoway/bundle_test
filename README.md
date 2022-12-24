This repo contains a test of a moderately complex interaction involving two-level namespace lookups of symbols from a loaded bundle.

To build, run `make` on macOS.

Here's the situation.

We have a `main` executable (souce code in `main.c`). It uses `dlopen()` to load `extension.bundle` (source code in `extension.c`) and call the `init()` function defined therein.

`main` also dynamically links to `libfoo1.dylib` (source code in `foo.c`). After the extension is loaded, `main` calls `foo_version()`.

The extension's `init()` calls `function_in_main()` which is a function defined in `main` itself.

The extension links to a static library, `libfoo2.a` (source code in `foo.c`) and also calls `foo_version()`.

All of these functions print their names when called.

This all works correctly.
```
$ ./main
foo_version(): 1
init()
function_in_main()
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
```

