#!/bin/sh
SCRIPT="package_gentoo_source.sh"
source "$(dirname $(readlink -f "$0"))/common.sh" $@
if [ $? -ne 0 ]; then exit 1; fi

# CMake build
printf "${PROGRESS}cmake --build \"${DEV_BINARY_DIR}\" --target package_gentoo_source${RESET}"
cmake --build "${DEV_BINARY_DIR}" --target package_gentoo_source
if [ $? -ne 0 ]; then printf "${ERROR}building target package_gentoo_source failed${RESET}"; exit 1; fi

# Create tarball
update_tar "${DEV_BINARY_DIR}/gentoo_source/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz" "${DEV_SOURCE_DIR}" "${DEV_BINARY_DIR}"
DEV_CHANGES=$?

# Create Manifest
if [ ! -f "${DEV_BINARY_DIR}/gentoo_source/Manifest" ]; then # Manifest does not exist
    DEV_CHANGES=1
fi
if [ ${DEV_CHANGES} -eq 0 ]; then # Tarball newer than Manifest
    if [ "${DEV_BINARY_DIR}/gentoo_source/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz" -nt "${DEV_BINARY_DIR}/gentoo_source/Manifest" ]; then DEV_CHANGES=1; fi
fi
if [ ${DEV_CHANGES} -eq 0 ]; then # Ebuild newer than Manifest
    if [ "${DEV_BINARY_DIR}/gentoo_source/${DEV_FILE_NAME}-${DEV_VERSION}.ebuild" -nt "${DEV_BINARY_DIR}/gentoo_source/Manifest" ]; then DEV_CHANGES=1; fi
fi
if [ ${DEV_CHANGES} -eq 0 ]; then # Metadata newer than Manifest
    if [ "${DEV_BINARY_DIR}/gentoo_source/metadata.xml" -nt "${DEV_BINARY_DIR}/gentoo_source/metadata.xml" ]; then DEV_CHANGES=1; fi
fi
if [ ${DEV_CHANGES} -ne 0 ]; then
    printf "${PROGRESS}Generating Manifest${RESET}"
    DEV_SIZE=$(stat "${DEV_BINARY_DIR}/gentoo_source/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz" --printf="%s")
    DEV_MD5=$(cmake -E md5sum "${DEV_BINARY_DIR}/gentoo_source/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz" | cut -d ' ' -f 1)
    echo DIST ${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz ${DEV_SIZE} MD5 ${DEV_MD5} | tee "${DEV_BINARY_DIR}/gentoo_source/Manifest"
    DEV_SIZE=$(stat "${DEV_BINARY_DIR}/gentoo_source/${DEV_FILE_NAME}-${DEV_VERSION}.ebuild" --printf="%s")
    DEV_MD5=$(cmake -E md5sum "${DEV_BINARY_DIR}/gentoo_source/${DEV_FILE_NAME}-${DEV_VERSION}.ebuild" | cut -d ' ' -f 1)
    echo EBUILD ${DEV_FILE_NAME}-${DEV_VERSION}.ebuild ${DEV_SIZE} MD5 ${DEV_MD5} | tee -a "${DEV_BINARY_DIR}/gentoo_source/Manifest"
    DEV_SIZE=$(stat "${DEV_BINARY_DIR}/gentoo_source/metadata.xml" --printf="%s")
    DEV_MD5=$(cmake -E md5sum "${DEV_BINARY_DIR}/gentoo_source/metadata.xml" | cut -d ' ' -f 1)
    echo MISC metadata.xml ${DEV_SIZE} MD5 ${DEV_MD5} | tee -a "${DEV_BINARY_DIR}/gentoo_source/Manifest"
fi
printf "${PROGRESS}success${RESET}"