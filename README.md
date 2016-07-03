# GCC cross compiler

Cross compiling GCC for a wide range of targets.

To build the toolchain, first edit any configuration options in `config.sh` and
then run:

```
FULL_REBUILD=1 bash ./build.sh
```

The build script will start from scratch, purging any existing toolchain. Be
sure this is what you want before you start the build process.

You can also specify some options on the commandline, e.g.:

```
FULL_REBUILD=1 GCC_VERSION=4.9.2 XC_TARGET_NAME=rpi2 bash ./build.sh
```

## Requirements

This software has only been tested on x86_64 systems running a recent version of
Linux. It will not work on Cygwin due to its lack of support for stat64 (see the
Cygwin FAQ for full details), which is used in glibc. It does not currently work
on OS X, as the kernel libraries will not build.

## Components

The following components are used when building the cross compiler:

 * [GNU Binutils](https://www.gnu.org/software/binutils/)
 * [Linux kernel](https://www.kernel.org/)
 * [GNU C library](https://www.gnu.org/software/libc/)
 * [GCC](https://gcc.gnu.org/)
 * [GNU MPFR](http://www.mpfr.org/)
 * [GNU GMP](https://gmplib.org/)
 
