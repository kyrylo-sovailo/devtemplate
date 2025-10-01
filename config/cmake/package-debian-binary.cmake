#######################################
# Creating binary packages for Debian #
#######################################

if (UNIX)
    # Create debian_binary folder
    file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/debian_binary/${DEV_FILE_NAME}/usr")

    # Generate control file
    string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" DEV_PROCESSOR)
    if("${DEV_PROCESSOR}" MATCHES "^(alpha|arm|armel|armhf|arm64|hppa|ia64|m68k|mips|mipsel|mips64el|powerpc|powerpcspe|ppc64|ppc64el|riscv64|s390|s390x|sh4|sparc|sparc64|x32)$")
        # nothing to do
    elseif("${DEV_PROCESSOR}" MATCHES "^(x86_64|x64)$")
        set(DEV_PROCESSOR "amd64")
    elseif("${DEV_PROCESSOR}" MATCHES "^(i686|x86|intel32)$")
        set(DEV_PROCESSOR "i386")
    else()
        message(WARNING "Could not recognize target architecture. Architecture of .deb files is set according to CMAKE_SYSTEM_PROCESSOR=${DEV_PROCESSOR}")
    endif()
    devtemplate_configure_file(${DEV_CMAKE_NAME}_debian_binary_control FALSE "${PROJECT_SOURCE_DIR}/config/template/debian_binary/control" "${PROJECT_BINARY_DIR}/debian_binary/${DEV_FILE_NAME}/DEBIAN/control")

    # Copy triggers file
    devtemplate_copy_file(${DEV_CMAKE_NAME}_debian_binary_triggers FALSE "${PROJECT_SOURCE_DIR}/config/static/debian_binary/triggers" "${PROJECT_BINARY_DIR}/debian_binary/${DEV_FILE_NAME}/DEBIAN/triggers")

    # Define pre-packaging target
    add_custom_target(package_debian_binary DEPENDS ${DEV_CORE_TARGETS} ${DEV_CMAKE_NAME}_debian_binary_control ${DEV_CMAKE_NAME}_debian_binary_triggers)
endif()
