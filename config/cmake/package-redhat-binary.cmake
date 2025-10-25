#######################################
# Creating binary packages for RedHat #
#######################################

if (UNIX)
    # Create redhat_binary folder
    file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/redhat_binary")

    # Generate spec file
    string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" DEV_PROCESSOR)
    if("${DEV_PROCESSOR}" MATCHES "^(alpha|arm|armel|armhf|arm64|hppa|i686|x86_64|ia64|m68k|mips|mipsel|mips64el|powerpc|powerpcspe|ppc64|ppc64el|riscv64|s390|s390x|sh4|sparc|sparc64|x32)$")
        # nothing to do
    elseif("${DEV_PROCESSOR}" MATCHES "^(amd64|x64)$")
        set(DEV_PROCESSOR "x86_64")
    elseif("${DEV_PROCESSOR}" MATCHES "^(i386|x86|intel32)$")
        set(DEV_PROCESSOR "i686")
    else()
        message(WARNING "Could not recognize target architecture. Architecture of .rpm files is set according to CMAKE_SYSTEM_PROCESSOR=${DEV_PROCESSOR}")
    endif()
    devtemplate_configure_file(${DEV_CMAKE_NAME}_redhat_binary_spec FALSE "${PROJECT_SOURCE_DIR}/config/template/redhat_binary/spec" "${PROJECT_BINARY_DIR}/redhat_binary/${DEV_FILE_NAME}-${DEV_VERSION}.spec")

    # Define pre-packaging target
    add_custom_target(package_redhat_binary DEPENDS ${DEV_CORE_TARGETS} ${DEV_CMAKE_NAME}_redhat_binary_spec)
endif()
