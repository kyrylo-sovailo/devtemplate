#!/bin/sh

ERROR="\033[01;31mpackage_debian_binary.sh: "
PROGRESS="\033[01;35mpackage_debian_binary.sh: "
RESET="\033[0m"

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
if [ ${DEV_ERROR} -ne 0 ]; then echo "${ERROR}Usage: ./package_debian_binary.sh <path to cmake binary directory>${RESET}"; exit 1; fi

# Get CMake version
DEV_CMAKE_MAJOR=$(cmake --version | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*' | cut -d '.' -f 1)
DEV_CMAKE_MINOR=$(cmake --version | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*' | cut -d '.' -f 2)
DEV_CMAKE_PATCH=$(cmake --version | grep -o -e '[0-9]*\.[0-9]*\.[0-9]*' | cut -d '.' -f 3)
if [ -z "${DEV_CMAKE_MAJOR}" ]; then DEV_ERROR=1; fi
if [ -z "${DEV_CMAKE_MINOR}" ]; then DEV_ERROR=1; fi
if [ -z "${DEV_CMAKE_PATCH}" ]; then DEV_ERROR=1; fi
if [ ${DEV_ERROR} -ne 0 ]; then echo "${ERROR}could not get CMake version${RESET}"; exit 1; fi
if [ ${DEV_CMAKE_MAJOR} -lt 3 ]; then DEV_CMAKE_CAN_INSTALL=0
elif [ ${DEV_CMAKE_MAJOR} -gt 3 ]; then DEV_CMAKE_CAN_INSTALL=1
elif [ ${DEV_CMAKE_MINOR} -ge 15 ]; then DEV_CMAKE_CAN_INSTALL=1
else DEV_CMAKE_CAN_INSTALL=0
fi

# Get package name
DEV_TEMPORARY_FILE=$(mktemp tmp.XXXXXXXXXX.cmake)
while IFS= read -r DEV_LINE; do
    echo "$DEV_LINE" | grep -qE '^\s*set\s*\(|^\s*string\s*\(|^\s*#|^\s*$'
    if [ $? -eq 0 ]; then echo "$DEV_LINE" >> "${DEV_TEMPORARY_FILE}"
    else break; fi
done < "${DEV_SOURCE_DIR}/CMakeLists.txt"
echo "message(\"DEV_FILE_NAME=\${DEV_FILE_NAME}\")" >> "${DEV_TEMPORARY_FILE}"
DEV_FILE_NAME=$(cmake -P "${DEV_TEMPORARY_FILE}"  2>&1 | grep -E '^DEV_FILE_NAME=')
DEV_FILE_NAME=${DEV_FILE_NAME#*=}
DEV_INSTALL_ROOT_DIR="${DEV_BINARY_DIR}/debian_binary/${DEV_FILE_NAME}"
rm "${DEV_TEMPORARY_FILE}"

# CMake configuration (avoid at all costs because of regenerating <configuration>.cmake)
if [ ! -f "${DEV_BINARY_DIR}/CMakeCache.txt" ]; then
    echo ${PROGRESS}cmake "${DEV_SOURCE_DIR}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH="/usr"${RESET}
    cmake "${DEV_SOURCE_DIR}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH="/usr"
    if [ $? -ne 0 ]; then echo "${ERROR}CMake configuration failed${RESET}"; exit 1; fi
fi

# CMake build
echo ${PROGRESS}cmake --build "${DEV_BINARY_DIR}" --target package_debian_binary${RESET}
cmake --build "${DEV_BINARY_DIR}" --target package_debian_binary
if [ $? -ne 0 ]; then echo "${ERROR}building target package_debian_binary failed${RESET}"; exit 1; fi

# Install
if [ ${DEV_CMAKE_CAN_INSTALL} -gt 0 ]; then
    echo ${PROGRESS}cmake --install "${DEV_BINARY_DIR}" --prefix "${DEV_INSTALL_ROOT_DIR}/usr"${RESET}
    cmake --install "${DEV_BINARY_DIR}" --prefix "${DEV_INSTALL_ROOT_DIR}/usr"
    if [ $? -ne 0 ]; then echo "${ERROR}installation to local directory failed${RESET}"; exit 1; fi
else
    echo ${PROGRESS}DESTDIR="${DEV_INSTALL_ROOT_DIR}/usr" cmake --install "${DEV_BINARY_DIR}"${RESET}
    DESTDIR="${DEV_INSTALL_ROOT_DIR}/usr" cmake --install "${DEV_BINARY_DIR}"
    if [ $? -ne 0 ]; then echo "${ERROR}installation to local directory failed${RESET}"; exit 1; fi
fi

# Cleanup
#TODO: the script is not cross-plaform anyway, replace by shell script?
#TODO: also implement re-doing when DEBIAN/* files change
cmake -P "${DEV_SOURCE_DIR}/config/cmake/script/check.cmake" -- "${DEV_BINARY_DIR}" "${DEV_INSTALL_ROOT_DIR}" "${DEV_INSTALL_ROOT_DIR}.deb"
if [ $? -ne 0 ]; then echo "${ERROR}cleaning of installation directory failed${RESET}"; exit 1; fi

# Package
if [ ! -f "${DEV_INSTALL_ROOT_DIR}.deb" ]; then
    find "${DEV_INSTALL_ROOT_DIR}/usr" -type d -exec chmod 755 {} \;
    dpkg-deb --root-owner-group --build "${DEV_INSTALL_ROOT_DIR}"
    if [ $? -ne 0 ]; then echo "${ERROR}creation of .deb package failed${RESET}"; exit 1; fi
fi
echo ${PROGRESS}success${RESET}