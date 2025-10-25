#!/bin/sh
SCRIPT="package_redhat_binary.sh"
source "$(dirname $(readlink -f "$0"))/common.sh" $@
if [ $? -ne 0 ]; then exit 1; fi
configure_and_get_variables redhat

# CMake build
printf "${PROGRESS}cmake --build \"${DEV_BINARY_DIR}\" --target package_redhat_binary${RESET}"
cmake --build "${DEV_BINARY_DIR}" --target package_redhat_binary
if [ $? -ne 0 ]; then printf "${ERROR}building target package_redhat_binary failed${RESET}"; exit 1; fi

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
if [ ! -f "${DEV_BINARY_DIR}/redhat_binary/${DEV_FILE_NAME}_${DEV_VERSION}.rpm" ]; then
    DEV_CHANGES=1
fi
if [ ${DEV_CHANGES} -eq 0 ]; then
    DEV_CHANGES=$(find "${DEV_BINARY_DIR}/install" -type f -newer "${DEV_BINARY_DIR}/redhat_binary/${DEV_FILE_NAME}_${DEV_VERSION}.rpm" | wc -l)
fi
if [ ${DEV_CHANGES} -eq 0 ]; then
    if [ "${DEV_BINARY_DIR}/redhat_binary/${DEV_FILE_NAME}-${DEV_VERSION}" -nt "${DEV_BINARY_DIR}/redhat_binary/${DEV_FILE_NAME}_${DEV_VERSION}.rpm" ]; then
        DEV_CHANGES=1
    fi
fi
if [ ${DEV_CHANGES} -ne 0 ]; then
    DEV_TEMP_DIRECTORY=$(mktemp -d)
    echo DEV_TEMP_DIRECTORY=$DEV_TEMP_DIRECTORY
    #trap 'rm -rf "${DEV_TEMP_DIRECTORY}"' EXIT
    mkdir "${DEV_TEMP_DIRECTORY}/BUILD/"
    mkdir "${DEV_TEMP_DIRECTORY}/RPMS/"
    mkdir "${DEV_TEMP_DIRECTORY}/SOURCES/"
    mkdir "${DEV_TEMP_DIRECTORY}/SPECS/"
    mkdir "${DEV_TEMP_DIRECTORY}/SRPMS/"
    mkdir "${DEV_TEMP_DIRECTORY}/BUILDROOT/"
    sed '/%files/q' "${DEV_BINARY_DIR}/redhat_binary/${DEV_FILE_NAME}-${DEV_VERSION}.spec" > "${DEV_TEMP_DIRECTORY}/SPECS/${DEV_FILE_NAME}-${DEV_VERSION}.spec"
    (cd "${DEV_BINARY_DIR}/" && find install -type f) | sed 's|^install||' >> "${DEV_TEMP_DIRECTORY}/SPECS/${DEV_FILE_NAME}-${DEV_VERSION}.spec"
    sed '1,/%files/d' "${DEV_BINARY_DIR}/redhat_binary/${DEV_FILE_NAME}-${DEV_VERSION}.spec" >> "${DEV_TEMP_DIRECTORY}/SPECS/${DEV_FILE_NAME}-${DEV_VERSION}.spec"
    printf "${PROGRESS}(cd \"${DEV_BINARY_DIR}/\" && tar --create --gzip install --file \"${DEV_TEMP_DIRECTORY}/SOURCES/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz\")${RESET}"
    (cd "${DEV_BINARY_DIR}/" && tar --create --gzip install --file "${DEV_TEMP_DIRECTORY}/SOURCES/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz")
    if [ $? -ne 0 ]; then printf "${ERROR}compression failed${RESET}"; exit 1; fi
    printf "${PROGRESS}rpmbuild --define \"_topdir ${DEV_TEMP_DIRECTORY}\" -bb \"${DEV_TEMP_DIRECTORY}/SPECS/${DEV_FILE_NAME}-${DEV_VERSION}.spec\"${RESET}"
    rpmbuild --define "_topdir ${DEV_TEMP_DIRECTORY}" -bb "${DEV_TEMP_DIRECTORY}/SPECS/${DEV_FILE_NAME}-${DEV_VERSION}.spec"
    if [ $? -ne 0 ]; then printf "${ERROR}creation of .rpm package failed${RESET}"; exit 1; fi
fi
printf "${PROGRESS}success${RESET}"
echo "You may now install ${DEV_FILE_NAME}_${DEV_VERSION}.rpm by running"
echo "1) apt install redhat_binary/${DEV_FILE_NAME}_${DEV_VERSION}.rpm"