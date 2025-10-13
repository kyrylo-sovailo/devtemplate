#!/bin/sh

ERROR="\033[01;31mpackage_debian_source.sh: "
PROGRESS="\033[01;35mpackage_debian_source.sh: "
RESET="\033[0m\n"

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
if [ ${DEV_ERROR} -ne 0 ]; then printf "${ERROR}Usage: ./package_debian_source.sh <path to cmake binary directory>${RESET}"; exit 1; fi

# Get package name
DEV_TEMPORARY_FILE=$(mktemp tmp.XXXXXXXXXX.cmake)
while IFS= read -r DEV_LINE; do
    echo "$DEV_LINE" | grep -qE '^\s*set\s*\(|^\s*string\s*\(|^\s*#|^\s*$'
    if [ $? -eq 0 ]; then echo "$DEV_LINE" >> "${DEV_TEMPORARY_FILE}"
    else break; fi
done < "${DEV_SOURCE_DIR}/CMakeLists.txt"
echo "message(\"DEV_FILE_NAME=\${DEV_FILE_NAME}\")" >> "${DEV_TEMPORARY_FILE}"
echo "message(\"DEV_VERSION=\${DEV_VERSION}\")" >> "${DEV_TEMPORARY_FILE}"
DEV_CMAKELISTS_PRINT=$(cmake -P "${DEV_TEMPORARY_FILE}" 2>&1)
DEV_FILE_NAME=$(echo "${DEV_CMAKELISTS_PRINT}" | grep -E '^DEV_FILE_NAME=')
DEV_FILE_NAME=${DEV_FILE_NAME#*=}
DEV_VERSION=$(echo "${DEV_CMAKELISTS_PRINT}" | grep -E '^DEV_VERSION=')
DEV_VERSION=${DEV_VERSION#*=}
DEV_PACKAGE_ROOT_DIR="${DEV_BINARY_DIR}/debian_source/${DEV_FILE_NAME}"
rm "${DEV_TEMPORARY_FILE}"

# CMake configuration
if [ ! -f "${DEV_BINARY_DIR}/CMakeCache.txt" ]; then
    printf "${PROGRESS}cmake \"${DEV_SOURCE_DIR}\"${RESET}"
    cmake "${DEV_SOURCE_DIR}"
    if [ $? -ne 0 ]; then printf "${ERROR}CMake configuration failed${RESET}"; exit 1; fi
fi

# CMake build
printf "${PROGRESS}cmake --build \"${DEV_BINARY_DIR}\" --target package_debian_source${RESET}"
cmake --build "${DEV_BINARY_DIR}" --target package_debian_source
if [ $? -ne 0 ]; then printf "${ERROR}building target package_debian_source failed${RESET}"; exit 1; fi

# Copy sources
case "${DEV_BINARY_DIR}" in
    ("${DEV_SOURCE_DIR}"/*)
        DEV_RELATIVE_BINARY_DIR=$(realpath "${DEV_BINARY_DIR}" --relative-to="${DEV_SOURCE_DIR}")
        DEV_CHANGES=$(rsync --itemize-changes --archive --delete "${DEV_SOURCE_DIR}/" "${DEV_PACKAGE_ROOT_DIR}/" --exclude='/.*' --exclude='/*Config.cmake' --exclude='/*.md' --exclude='/debian/' --exclude="/${DEV_RELATIVE_BINARY_DIR}/" | wc -l)
        ;;
    (*)
        DEV_CHANGES=$(rsync --itemize-changes --archive --delete "${DEV_SOURCE_DIR}/" "${DEV_PACKAGE_ROOT_DIR}/" --exclude='/.*' --exclude='/*Config.cmake' --exclude='/*.md' --exclude='/debian/' | wc -l)
        ;;
esac
if [ $? -ne 0 ]; then printf "${ERROR}Copying sources failed failed${RESET}"; exit 1; fi

# Package
if [ ${DEV_CHANGES} -eq 0 ]; then
    if [ ! -f "${DEV_PACKAGE_ROOT_DIR}_${DEV_VERSION}.dsc" ]; then DEV_CHANGES=1; fi
fi
if [ ${DEV_CHANGES} -eq 0 ]; then
    DEV_CHANGES=$(find "${DEV_PACKAGE_ROOT_DIR}/debian" -type f -newer "${DEV_PACKAGE_ROOT_DIR}_${DEV_VERSION}.dsc" | wc -l)
fi
if [ ${DEV_CHANGES} -gt 0 ]; then
    dpkg-source --build "${DEV_PACKAGE_ROOT_DIR}"
    if [ $? -ne 0 ]; then printf "${ERROR}creation of .dsc package failed${RESET}"; exit 1; fi
    mv "${DEV_BINARY_DIR}/${DEV_FILE_NAME}_${DEV_VERSION}.dsc" "${DEV_BINARY_DIR}/debian_source/"
    if [ $? -ne 0 ]; then printf "${ERROR}creation of .dsc package failed${RESET}"; exit 1; fi
    mv "${DEV_BINARY_DIR}/${DEV_FILE_NAME}_${DEV_VERSION}.tar".* "${DEV_BINARY_DIR}/debian_source/"
    if [ $? -ne 0 ]; then printf "${ERROR}creation of .dsc package failed${RESET}"; exit 1; fi
fi
printf "${PROGRESS}success${RESET}"