#!/bin/sh
SCRIPT="package_debian_source.sh"
source "$(dirname $(readlink -f "$0"))/common.sh" $@
if [ $? -ne 0 ]; then exit 1; fi
configure_and_get_variables debian

# CMake build
printf "${PROGRESS}cmake --build \"${DEV_BINARY_DIR}\" --target package_debian_source${RESET}"
cmake --build "${DEV_BINARY_DIR}" --target package_debian_source
if [ $? -ne 0 ]; then printf "${ERROR}building target package_debian_source failed${RESET}"; exit 1; fi

# Create package
DEV_CHANGES=0
if [ ! -f "${DEV_BINARY_DIR}/debian_source/${DEV_FILE_NAME}_${DEV_VERSION}.dsc" ]; then #Package does not exist
    DEV_CHANGES=1
fi
if [ ! -f "${DEV_BINARY_DIR}/debian_source/${DEV_FILE_NAME}_${DEV_VERSION}.tar.xz" ]; then #Tarball does not exist
    DEV_CHANGES=1
fi
if [ ${DEV_CHANGES} -eq 0 ]; then #Source newer than tarball
    check_source_tar "${DEV_BINARY_DIR}/debian_source/${DEV_FILE_NAME}_${DEV_VERSION}.tar.xz"
fi
#if [ ${DEV_CHANGES} -eq 0 ]; then #Metafile newer than package
#    for DEV_META_FILE in control changelog copyright rules compat format; do
#        if [ "${DEV_BINARY_DIR}/debian_source/${DEV_META_FILE}" -nt "${DEV_BINARY_DIR}/debian_source/${DEV_FILE_NAME}_${DEV_VERSION}.dsc" ]; then
#            DEV_CHANGES=1
#        fi
#    done
#fi
if [ ${DEV_CHANGES} -ne 0 ]; then
    #Create temporary directory
    DEV_TEMP_DIRECTORY=$(mktemp -d)
    trap 'rm -rf "${DEV_TEMP_DIRECTORY}"' EXIT
    mkdir -p "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}/debian/source"
    #Copy files
    for DEV_META_FILE in control changelog copyright rules compat; do
        cp "${DEV_BINARY_DIR}/debian_source/${DEV_META_FILE}" "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}/debian/"
    done
    cp "${DEV_BINARY_DIR}/debian_source/format" "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}/debian/source"
    copy_source_files "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}"
    #Create package
    printf "${PROGRESS}(cd \"${DEV_BINARY_DIR}/debian_source\" && dpkg-source --build \"${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}\")${RESET}"
    (cd "${DEV_BINARY_DIR}/debian_source" && dpkg-source --build "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}")
    if [ $? -ne 0 ]; then printf "${ERROR}creation of .dsc file failed${RESET}"; exit 1; fi
fi

printf "${PROGRESS}success${RESET}"
echo "You may now build ${DEV_FILE_NAME}_${DEV_VERSION}.deb by running"
echo "1) cd debian_source/"
echo "2) dpkg-source -x ${DEV_FILE_NAME}_${DEV_VERSION}.dsc"
echo "3) cd debian_source/${DEV_FILE_NAME}-${DEV_VERSION}/"
echo "4) dpkg-buildpackage -us -uc"