#!/bin/sh
SCRIPT="package_debian_binary.sh"
source "$(dirname $(readlink -f "$0"))/common.sh" $@
if [ $? -ne 0 ]; then exit 1; fi
configure_and_get_variables debian

# CMake build
printf "${PROGRESS}cmake --build \"${DEV_BINARY_DIR}\" --target package_debian_binary${RESET}"
cmake --build "${DEV_BINARY_DIR}" --target package_debian_binary
if [ $? -ne 0 ]; then printf "${ERROR}building target package_debian_binary failed${RESET}"; exit 1; fi

# Install
if [ ${DEV_CMAKE_CAN_INSTALL} -gt 0 ]; then
    printf "${PROGRESS}cmake --install \"${DEV_BINARY_DIR}\" --prefix \"${DEV_BINARY_DIR}/install/usr\"${RESET}"
    cmake --install "${DEV_BINARY_DIR}" --prefix "${DEV_BINARY_DIR}/install/usr"
    if [ $? -ne 0 ]; then printf "${ERROR}installation to local directory failed${RESET}"; exit 1; fi
else
    printf "${PROGRESS}DESTDIR=\"${DEV_BINARY_DIR}/install/usr\" cmake --install \"${DEV_BINARY_DIR}\"${RESET}"
    DESTDIR="${DEV_BINARY_DIR}/install/usr" cmake --install "${DEV_BINARY_DIR}"
    if [ $? -ne 0 ]; then printf "${ERROR}installation to local directory failed${RESET}"; exit 1; fi
fi
DEV_CHANGES=0
find "${DEV_BINARY_DIR}/install" -type f | while IFS= read -r DEV_FILE; do
    # TODO: replace by .cmake script?
    if ! grep -qxF "${DEV_FILE}" "${DEV_BINARY_DIR}/install_manifest.txt"; then
        rm "${DEV_FILE}"
        DEV_CHANGES=1
    fi
done

# Create package
if [ ! -f "${DEV_BINARY_DIR}/debian_binary/${DEV_FILE_NAME}_${DEV_VERSION}.deb" ]; then
    DEV_CHANGES=1
fi
if [ ${DEV_CHANGES} -eq 0 ]; then
    DEV_CHANGES=$(find "${DEV_BINARY_DIR}/install" -type f -newer "${DEV_BINARY_DIR}/debian_binary/${DEV_FILE_NAME}_${DEV_VERSION}.deb" | wc -l)
fi
if [ ${DEV_CHANGES} -eq 0 ]; then
    for DEV_META_FILE in control triggers; do
        if [ "${DEV_BINARY_DIR}/debian_binary/${DEV_META_FILE}" -nt "${DEV_BINARY_DIR}/debian_binary/${DEV_FILE_NAME}_${DEV_VERSION}.deb" ]; then
            DEV_CHANGES=1
        fi
    done
fi
if [ ${DEV_CHANGES} -ne 0 ]; then
    DEV_TEMP_DIRECTORY=$(mktemp -d)
    trap 'rm -rf "${DEV_TEMP_DIRECTORY}"' EXIT
    mkdir -p "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}/DEBIAN"
    for DEV_META_FILE in control triggers; do
        cp "${DEV_BINARY_DIR}/debian_binary/${DEV_META_FILE}" "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}/DEBIAN/"
    done
    cp -r "${DEV_BINARY_DIR}/install/"* "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}/"
    find "${DEV_TEMP_DIRECTORY}" -type d -exec chmod 755 {} \;
    printf "${PROGRESS}dpkg-deb --root-owner-group --build \"${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}\"${RESET}"
    dpkg-deb --root-owner-group --build "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}"
    if [ $? -ne 0 ]; then printf "${ERROR}creation of .deb package failed${RESET}"; exit 1; fi
    cp "${DEV_TEMP_DIRECTORY}/${DEV_FILE_NAME}.deb" "${DEV_BINARY_DIR}/debian_binary/${DEV_FILE_NAME}_${DEV_VERSION}.deb"
    if [ $? -ne 0 ]; then printf "${ERROR}file copying failed${RESET}"; exit 1; fi
fi
printf "${PROGRESS}success${RESET}"
echo "You may now install ${DEV_FILE_NAME}_${DEV_VERSION}.deb by running"
echo "1) apt install debian_binary/${DEV_FILE_NAME}_${DEV_VERSION}.deb"