########################
# Packaging for Debian #
########################

# Create debian folder
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/debian/${DEV_FILE_NAME}/usr")

# Generate control file
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" DEV_PROCESSOR)
if ("${DEV_PROCESSOR}" STREQUAL "x86_64" OR "${DEV_PROCESSOR}" STREQUAL "x64" OR "${DEV_PROCESSOR}" STREQUAL "amd64")
    set(DEV_PROCESSOR "amd64")
elseif("${DEV_PROCESSOR}" STREQUAL "i686" OR "${DEV_PROCESSOR}" STREQUAL "x86" OR "${DEV_PROCESSOR}" STREQUAL "intel32")
    set(DEV_PROCESSOR "i386")
else()
    message(WARNING "Could not recognize target architecture. Architecture of .deb files is set according to CMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}")
endif()
devtemplate_configure_file(INPUT "${PROJECT_SOURCE_DIR}/config/template/control"
    OUTPUT "${PROJECT_BINARY_DIR}/debian/${DEV_FILE_NAME}/DEBIAN/control")

# Define pre-packaging target
add_custom_target(debian_package DEPENDS ${DEV_PACKAGE_TARGETS} "${PROJECT_BINARY_DIR}/debian/${DEV_FILE_NAME}/DEBIAN/control")