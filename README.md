# xmrig cross builder

This repo holds the Makefile to compile a statically linked xmrig program using a cross compiler toolchain.

The patch held in this repo, `openssl-cross-fix.patch` makes sure that CMake does not pick up OpenSSL/LibreSSL link flags for the hosting build system.

The environment variable `MAKEOPTS` can be set so that the dependencies and xmrig can be built quickly: `MAKEOPTS=-j18` for a 16-core build system.

The make variables `TARGET`, `PREFIX`, and `ARCH` must be set so the build can complete without errors. You may need to patch your toolchain's headers in order to compile xmrig without errors, especially for aarch64's `arm_acle.h` if you use musl-cross-make.

## Known issues

- The Makefile will not fetch xmrig, its dependencies, and a cross compiler toolchain automatically. You may send a PR to implement this feature.
- When you remove xmrig from the source tree, do not forget to remove `.xmrig-patched` file from the source tree as well. Failing to do so may cause build failures.

## Build dependencies

- autotools
- cmake
- make
- hwloc
- libressl
- libuv

## Instructions

1. Source a cross compile toolchain that has and can statically link all runtime libraries (including libc). I recommend using musl-cross-make to source your toolchain. Here, we will use aarch64-linux-musl as the target to demonstrate.
2. Download and verify the source code tarballs for hwloc, libressl, libuv, and xmrig.
3. Extract the tarballs into the source tree.
4. Rename the extracted directories so that they do not contain the version number. For example: `xmrig-6.26.0` -> `xmrig`
5. Run `make TARGET=aarch64-linux-musl PREFIX=/path/to/toolchain ARCH=aarch64`. This will build xmrig and its dependencies. Note, that you can set `MAKEOPTS` for your builds to go faster.
6. The compiled program will be in `xmrig/build/xmrig`.
