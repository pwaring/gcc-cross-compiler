# GCC cross compiler

Cross compiling GCC for a range of targets. This project was started to make the
process as simple as possible, in order to help people understand how a cross
compiler (and associated toolchain) is built.

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

See the Environment variables section for full details.

## Environment variables

The build script supports the following environment variables:

 * `FULL_REBUILD`: If set, the toolchain will be rebuilt from scratch.
 * `XC_TARGET_NAME`: Specify a human-readable target, e.g. `rpi2` for the
 Raspberry Pi 2. This will automatically set the correct cross compiler and
 kernel options.
 * `XC_TARGET`: The target architecture for the toolchain. Depending on the
 architecture, you may need all parts of the triplet (e.g. for a Raspberry Pi
 you should set XC_TARGET to "arm-unknown-linux-gnueabihf"). Required if
 `XC_TARGET_NAME` is not set.
 * `XC_KERNEL_TARGET`: Kernel target architecture. The kernel has slightly
 different names for its targets, e.g. for a RPi you shoud set this to "arm".
 Required if `XC_TARGET_NAME` is not set.
 * `GCC_VERSION`: Version of GCC to use. This currently defaults to the latest
 5.x series. The cross compiler is more likely to build if you use a version
 close to that on the host (e.g. don't try and build a 5.x cross compiler on a
 host with GCC 4.x).
 * `PARALLEL_BUILDS`: Maximum number of parallel builds (passed to `make` as
   `-j ${PARALLEL_BUILDS}`). Requires GNU Make 4.0 or later.

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

## Alternatives

This is not the only GCC cross compiler project. Some alternatives which may
work better, offer more flexibility etc. include:

 * [crosstool-ng](http://crosstool-ng.org/)

You may also be able to install cross compilers for certain architectures via
your package management system. For example, on Ubuntu the
`gcc-arm-linux-gnueabi` package will provide you with a cross compiler for 32
bit ARM on a x86 or x86_64 host.

## Further reading

 * [How to Build a GCC Cross-Compiler](http://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/):
 Blog post which was used as the starting point for this project.
 * [GCC Cross-Compiler](http://wiki.osdev.org/GCC_Cross-Compiler): Useful bits
 of information aimed at people looking to get involved in operating system
 development, particularly embedded systems.
 * [Windows-to-RaspberryPi (Jessie) Cross Compiler Guide](http://www.gurucoding.com/en/rpi_cross_compiler_jessie/index.php)
