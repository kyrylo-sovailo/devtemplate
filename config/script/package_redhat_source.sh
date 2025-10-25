#!/bin/sh
SCRIPT="package_redhat_source.sh"
source "$(dirname $(readlink -f "$0"))/common.sh" $@
if [ $? -ne 0 ]; then exit 1; fi
configure_and_get_variables redhat

# CMake build
printf "${PROGRESS}cmake --build \"${DEV_BINARY_DIR}\" --target package_redhat_source${RESET}"
cmake --build "${DEV_BINARY_DIR}" --target package_redhat_source
if [ $? -ne 0 ]; then printf "${ERROR}building target package_redhat_source failed${RESET}"; exit 1; fi

# Create tarball
update_source_tar "${DEV_BINARY_DIR}/redhat_source/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz" #TODO: share with gentoo?

# Create package
DEV_CHANGES=0
if [ ! -f "${DEV_BINARY_DIR}/redhat_source/${DEV_FILE_NAME}-${DEV_VERSION}.src.rpm" ]; then #Package does not exist
    DEV_CHANGES=1
fi
if [ ${DEV_CHANGES} -eq 0 ]; then #Source newer than package
    if [ "${DEV_BINARY_DIR}/redhat_source/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz" -nt "${DEV_BINARY_DIR}/redhat_source/${DEV_FILE_NAME}-${DEV_VERSION}.src.rpm" ]; then
        DEV_CHANGES=1
    fi
fi
if [ ${DEV_CHANGES} -ne 0 ]; then
    #Create temporary directory
    DEV_TEMP_DIRECTORY=$(mktemp -d)
    trap 'rm -rf "${DEV_TEMP_DIRECTORY}"' EXIT
    mkdir "${DEV_TEMP_DIRECTORY}/BUILD/"
    mkdir "${DEV_TEMP_DIRECTORY}/RPMS/"
    mkdir "${DEV_TEMP_DIRECTORY}/SOURCES/"
    mkdir "${DEV_TEMP_DIRECTORY}/SPECS/"
    mkdir "${DEV_TEMP_DIRECTORY}/SRPMS/"
    mkdir "${DEV_TEMP_DIRECTORY}/BUILDROOT/"
    #Copy files
    cp "${DEV_BINARY_DIR}/redhat_source/${DEV_FILE_NAME}-${DEV_VERSION}.spec" "${DEV_TEMP_DIRECTORY}/SPECS"
    cp "${DEV_BINARY_DIR}/redhat_source/${DEV_FILE_NAME}-${DEV_VERSION}.tar.gz" "${DEV_TEMP_DIRECTORY}/SOURCE"
    #Create package
    printf "${PROGRESS}rpmbuild --define \"_topdir ${DEV_TEMP_DIRECTORY}\" -bs \"${DEV_TEMP_DIRECTORY}/SPECS/${DEV_FILE_NAME}-${DEV_VERSION}.spec\"${RESET}"
    rpmbuild --define "_topdir ${DEV_TEMP_DIRECTORY}" -bs "${DEV_TEMP_DIRECTORY}/SPECS/${DEV_FILE_NAME}-${DEV_VERSION}.spec"
    if [ $? -ne 0 ]; then printf "${ERROR}creation of .src.rpm package failed${RESET}"; exit 1; fi
fi

printf "${PROGRESS}success${RESET}"
echo "You may now build binary ${DEV_FILE_NAME}-${DEV_VERSION}.rpm by running one of the following"
echo "1) rpmdev-setuptree"
echo "2) rpm -ivh redhat_source/${DEV_FILE_NAME}-${DEV_VERSION}.rpm"
echo "3) rpmbuild -bb ~/rpmbuild/SPECS/${DEV_FILE_NAME}.spec"