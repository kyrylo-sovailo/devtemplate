#######################################
# Creating source packages for RedHat #
#######################################

if (UNIX)
    # Create redhat_source folder
    file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/redhat_source")

    # Generate spec file
    devtemplate_configure_file(${DEV_CMAKE_NAME}_redhat_source_spec FALSE "${PROJECT_SOURCE_DIR}/config/template/redhat_source/spec" "${PROJECT_BINARY_DIR}/redhat_source/${DEV_FILE_NAME}-${DEV_VERSION}.spec")

    # Define pre-packaging target
    add_custom_target(package_redhat_source DEPENDS ${DEV_CMAKE_NAME}_redhat_source_spec)
endif()
