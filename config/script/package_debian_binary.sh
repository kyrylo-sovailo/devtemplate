#!/bin/sh
SCRIPT="package_debian_binary.sh"
source "$(dirname $(readlink -f "$0"))/common.sh" $@
if [ $? -eq 0 ]; then exit 1; fi
exit

# CMake configuration (avoid at all costs because of regenerating <configuration>.cmake)
if [ ! -f "${DEV_BINARY_DIR}/CMakeCache.txt" ]; then
    printf "${PROGRESS}cmake \"${DEV_SOURCE_DIR}\" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DDEV_DOCUMENTATION_FORMAT=gz -DDEV_DOCUMENTATION_FORMAT=gz${RESET}"
    cmake "${DEV_SOURCE_DIR}" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
    if [ $? -ne 0 ]; then printf "${ERROR}CMake configuration failed${RESET}"; exit 1; fi
fi

# CMake build
printf "${PROGRESS}cmake --build \"${DEV_BINARY_DIR}\" --target package_debian_binary${RESET}"
cmake --build "${DEV_BINARY_DIR}" --target package_debian_binary
if [ $? -ne 0 ]; then printf "${ERROR}building target package_debian_binary failed${RESET}"; exit 1; fi

# Install
if [ ${DEV_CMAKE_CAN_INSTALL} -gt 0 ]; then
    printf "${PROGRESS}cmake --install \"${DEV_BINARY_DIR}\" --prefix \"${DEV_INSTALL_ROOT_DIR}/usr\"${RESET}"
    cmake --install "${DEV_BINARY_DIR}" --prefix "${DEV_INSTALL_ROOT_DIR}/usr"
    if [ $? -ne 0 ]; then printf "${ERROR}installation to local directory failed${RESET}"; exit 1; fi
else
    printf "${PROGRESS}DESTDIR=\"${DEV_INSTALL_ROOT_DIR}/usr\" cmake --install \"${DEV_BINARY_DIR}\"${RESET}"
    DESTDIR="${DEV_INSTALL_ROOT_DIR}/usr" cmake --install "${DEV_BINARY_DIR}"
    if [ $? -ne 0 ]; then printf "${ERROR}installation to local directory failed${RESET}"; exit 1; fi
fi

# Cleanup
#TODO: the script is not cross-plaform anyway, replace by shell script?
#TODO: also implement re-doing when DEBIAN/* files change
cmake -P "${DEV_SOURCE_DIR}/config/cmake/script/check.cmake" -- "${DEV_BINARY_DIR}" "${DEV_INSTALL_ROOT_DIR}" "${DEV_INSTALL_ROOT_DIR}.deb"
if [ $? -ne 0 ]; then printf "${ERROR}cleaning of installation directory failed${RESET}"; exit 1; fi

# Package
if [ ! -f "${DEV_INSTALL_ROOT_DIR}.deb" ]; then
    find "${DEV_INSTALL_ROOT_DIR}/usr" -type d -exec chmod 755 {} \;
    dpkg-deb --root-owner-group --build "${DEV_INSTALL_ROOT_DIR}"
    if [ $? -ne 0 ]; then printf "${ERROR}creation of .deb package failed${RESET}"; exit 1; fi
fi
printf "${PROGRESS}success${RESET}"