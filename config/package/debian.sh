#!/bin/sh

# Check arguments
DEV_ERROR=0
if [   -z "$0" ]; then DEV_ERROR=1; fi
if [ ! -f "$0" ]; then DEV_ERROR=1; fi
if [   -z "$1" ]; then DEV_ERROR=1; fi
if [ ! -d "$1" ]; then DEV_ERROR=1; fi
if [   -n "$2" ]; then DEV_ERROR=1; fi
DEV_BINARY_DIR=$(readlink -f "$1")
DEV_SOURCE_DIR=$(readlink -f "$0")
DEV_SOURCE_DIR=$(dirname "${DEV_SOURCE_DIR}")
DEV_SOURCE_DIR=$(dirname "${DEV_SOURCE_DIR}")
DEV_SOURCE_DIR=$(dirname "${DEV_SOURCE_DIR}")
if [ ${DEV_ERROR} -ne 0 ]; then echo "debian.sh usage: ./debian.sh <path to cmake binary directory>"; exit 1; fi

# Get CMake version
DEV_CMAKE_MAJOR=$(cmake --version | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*' | cut -d '.' -f 1)
DEV_CMAKE_MINOR=$(cmake --version | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*' | cut -d '.' -f 2)
DEV_CMAKE_PATCH=$(cmake --version | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*' | cut -d '.' -f 3)
if [ -z "${DEV_CMAKE_MAJOR}" ]; then DEV_ERROR=1; fi
if [ -z "${DEV_CMAKE_MINOR}" ]; then DEV_ERROR=1; fi
if [ -z "${DEV_CMAKE_PATCH}" ]; then DEV_ERROR=1; fi
if [ ${DEV_ERROR} -ne 0 ]; then echo "debian.sh: could not get CMake version"; exit 1; fi

# Initial CMake configuration
cd "${DEV_BINARY_DIR}"
if [ ! -d "${DEV_BINARY_DIR}/debian" ]; then
    cmake "${DEV_SOURCE_DIR}"
    if [ $? -ne 0 ]; then echo "debian.sh: initial CMake configuration failed"; exit 1; fi
fi
DEV_INSTALL_ROOT=$(find "${DEV_BINARY_DIR}/debian" -mindepth 1 -maxdepth 1 -type d)
if [ $(echo "${DEV_INSTALL_ROOT}" | wc -l) -ne 1 ]; then echo "debian.sh: debian directory has no or more than one subdirectories"; exit 1; fi

# Secondary CMake configuration, build and installation
if [ ${DEV_CMAKE_MAJOR} -lt 3 ]; then DEV_NEW=0
elif [ ${DEV_CMAKE_MAJOR} -gt 3 ]; then DEV_NEW=1
elif [ ${DEV_CMAKE_MINOR} -ge 15 ]; then DEV_NEW=1
else DEV_NEW=0
fi

if [ ${DEV_NEW} -gt 0 ]; then
    cmake --build "${DEV_BINARY_DIR}" --target package_debian
    if [ $? -ne 0 ]; then echo "debian.sh: building target package_debian failed"; exit 1; fi
    cmake --install "${DEV_BINARY_DIR}" --prefix "${DEV_INSTALL_ROOT}/usr"
    if [ $? -ne 0 ]; then echo "debian.sh: installation to local directory failed"; exit 1; fi
else
    cmake -DCMAKE_INSTALL_PREFIX:PATH="${DEV_INSTALL_ROOT}/usr" "${DEV_SOURCE_DIR}"
    if [ $? -ne 0 ]; then echo "debian.sh: CMake configuration failed"; exit 1; fi
    cmake --build "${DEV_BINARY_DIR}" --target package_debian
    if [ $? -ne 0 ]; then echo "debian.sh: building target package_debian failed"; exit 1; fi
    cmake --build "${DEV_BINARY_DIR}" --target install
    if [ $? -ne 0 ]; then echo "debian.sh: installation to local directory failed"; exit 1; fi
fi

# Cleanup
cmake -P "${DEV_SOURCE_DIR}/config/script/check.cmake" -- "${DEV_BINARY_DIR}" "${DEV_INSTALL_ROOT}" "${DEV_INSTALL_ROOT}.deb"
if [ $? -ne 0 ]; then echo "debian.sh: cleaning of installation directory failed"; exit 1; fi

# Package
if [ ! -f "${DEV_INSTALL_ROOT}.deb" ]; then
    dpkg-deb --root-owner-group --build "${DEV_INSTALL_ROOT}"
    if [ $? -ne 0 ]; then echo "debian.sh: creation of .deb package failed"; exit 1; fi
fi
echo debian.sh: success