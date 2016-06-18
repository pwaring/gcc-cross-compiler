#!/bin/bash

set -u
set -e

source ./config.sh

export FULL_REBUILD=${FULL_REBUILD:-}

if [ ! -z ${FULL_REBUILD} ]; then
  echo "You are about to rebuild the entire toolchain from scratch"
  echo "This will remove any changes you have made to the source files"
  echo "and take substantially longer than a partial rebuild"
  read -p "Are you sure this is what you want? (y/n) " confirm
  case $confirm in
    [Nn] ) exit;;
  esac
fi

if [ ! -z ${FULL_REBUILD} ]; then
  # Remove and then recreate prefix directory
  if [ -d ${XC_PREFIX} ]; then
    rm -rf ${XC_PREFIX}
  fi

  mkdir ${XC_PREFIX}
fi

# Create tarball directory if it does not already exist
if [ ! -d ${XC_TARBALL_DIR} ]; then
  mkdir -p ${XC_TARBALL_DIR}
fi

# Create temp directory if it does not already exist
if [ ! -d ${XC_TMP_DIR} ]; then
  mkdir -p ${XC_TMP_DIR}
fi

# Download all tarballs
if [ ! -x ${FULL_REBUILD} ]; then
  # Binutils
  if [ ! -f ${BINUTILS_TARBALL} ]; then
    wget ${BINUTILS_URL} -O ${BINUTILS_TARBALL}
  fi

  # Linux
  if [ ! -f ${KERNEL_TARBALL} ]; then
    wget ${KERNEL_URL} -O ${KERNEL_TARBALL}
  fi

  # Glibc
  if [ ! -f ${GLIBC_TARBALL} ]; then
    wget ${GLIBC_URL} -O ${GLIBC_TARBALL}
  fi

  # GCC
  if [ ! -f ${GCC_TARBALL} ]; then
    wget ${GCC_URL} -O ${GCC_TARBALL}
  fi

  # MPFR
  if [ ! -f ${MPFR_TARBALL} ]; then
    wget ${MPFR_URL} -O ${MPFR_TARBALL}
  fi

  # MPC
  if [ ! -f ${MPC_TARBALL} ]; then
    wget ${MPC_URL} -O ${MPC_TARBALL}
  fi

  # GMP
  if [ ! -f ${GMP_TARBALL} ]; then
    wget ${GMP_URL} -O ${GMP_TARBALL}
  fi

  # ISL
  if [ ! -f ${ISL_TARBALL} ]; then
    wget ${ISL_URL} -O ${ISL_TARBALL}
  fi

  # Cloog
  if [ ! -f ${CLOOG_TARBALL} ]; then
    wget ${CLOOG_URL} -O ${CLOOG_TARBALL}
  fi
fi

# Extract all tarballs
if [ ! -z ${FULL_REBUILD} ]; then
  # Binutils
  if [ -d ${BINUTILS_SRC_DIR} ]; then
    rm -rf ${BINUTILS_SRC_DIR}
  fi

  tar -xvf ${BINUTILS_TARBALL} -C ${XC_TMP_DIR}

  # Linux
  if [ -d ${KERNEL_SRC_DIR} ]; then
    rm -rf ${KERNEL_SRC_DIR}
  fi

  tar -xvf ${KERNEL_TARBALL} -C ${XC_TMP_DIR}

  # glibc
  if [ -d ${GLIBC_SRC_DIR} ]; then
    rm -rf ${GLIBC_SRC_DIR}
  fi

  tar -xvf ${GLIBC_TARBALL} -C ${XC_TMP_DIR}

  # GCC
  if [ -d ${GCC_SRC_DIR} ]; then
    rm -rf ${GCC_SRC_DIR}
  fi

  tar -xvf ${GCC_TARBALL} -C ${XC_TMP_DIR}

  # Patch GCC
  find ${XC_SRC_DIR} -type f -exec sed -i 's/struct stat64/struct stat/g' {} \;

  # MPFR
  if [ -d ${MPFR_SRC_DIR} ]; then
    rm -rf ${MPFR_SRC_DIR}
  fi

  tar -xvf ${MPFR_TARBALL} -C ${XC_TMP_DIR}
  ln -s ${MPFR_SRC_DIR} ${GCC_SRC_DIR}/mpfr

  # MPC
  if [ -d ${MPC_SRC_DIR} ]; then
    rm -rf ${MPC_SRC_DIR}
  fi

  tar -xvf ${MPC_TARBALL} -C ${XC_TMP_DIR}
  ln -s ${MPC_SRC_DIR} ${GCC_SRC_DIR}/mpc

  # GMP
  if [ -d ${GMP_SRC_DIR} ]; then
    rm -rf ${GMP_SRC_DIR}
  fi

  tar -xvf ${GMP_TARBALL} -C ${XC_TMP_DIR}
  ln -s ${GMP_SRC_DIR} ${GCC_SRC_DIR}/gmp

  # ISL
  if [ -d ${ISL_SRC_DIR} ]; then
    rm -rf ${ISL_SRC_DIR}
  fi

  tar -xvf ${ISL_TARBALL} -C ${XC_TMP_DIR}
  ln -s ${ISL_SRC_DIR} ${GCC_SRC_DIR}/isl

  # Cloog
  if [ -d ${CLOOG_SRC_DIR} ]; then
    rm -rf ${CLOOG_SRC_DIR}
  fi

  tar -xvf ${CLOOG_TARBALL} -C ${XC_TMP_DIR}
  ln -s ${CLOOG_SRC_DIR} ${GCC_SRC_DIR}/cloog
fi

# Build binutils
# Remove and recreate the build directory
if [ -d ${BINUTILS_BUILD_DIR} ]; then
  rm -rf ${BINUTILS_BUILD_DIR}
fi

mkdir ${BINUTILS_BUILD_DIR}

cd ${BINUTILS_BUILD_DIR}
${BINUTILS_SRC_DIR}/configure ${BINUTILS_CONFIGURE_OPTIONS[*]}
make
make install

# Build kernel headers (no need for separate build directory)
cd ${KERNEL_SRC_DIR}
make ${KERNEL_MAKE_OPTIONS[*]}

# Build GCC (first pass)
# Remove and recreate the build directory
if [ -d ${GCC_BUILD_DIR} ]; then
  rm -rf ${GCC_BUILD_DIR}
fi

mkdir ${GCC_BUILD_DIR}

cd ${GCC_BUILD_DIR}
${GCC_SRC_DIR}/configure ${GCC_CONFIGURE_OPTIONS[*]}
make all-gcc
make install-gcc

# Build glibc (first pass)
# Remove and recreate the build directory
if [ -d ${GLIBC_BUILD_DIR} ]; then
  rm -rf ${GLIBC_BUILD_DIR}
fi

mkdir ${GLIBC_BUILD_DIR}

cd ${GLIBC_BUILD_DIR}
${GLIBC_SRC_DIR}/configure ${GLIBC_CONFIGURE_OPTIONS[*]}
make install-bootstrap-headers=yes install-headers
make csu/subdir_lib
install csu/crt1.o csu/crti.o csu/crtn.o ${XC_HEADER_DIR}/lib
${XC_TARGET}-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o ${XC_HEADER_DIR}/lib/libc.so
touch ${XC_HEADER_DIR}/include/gnu/stubs.h


# Build GCC (second pass)
cd ${GCC_BUILD_DIR}
make all-target-libgcc
make install-target-libgcc

# Build glibc (second pass)
cd ${GLIBC_BUILD_DIR}
make
make install

# Build and install GCC (third pass)
cd ${GCC_BUILD_DIR}
make all
make install
