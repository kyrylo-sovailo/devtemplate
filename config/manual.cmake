###################
# Generate manual #
###################
if (NOT WIN32)
    # Generate manual
    devtemplate_configure_file(${DEV_CMAKE_NAME}_man_raw FALSE "${PROJECT_SOURCE_DIR}/config/template/man.1" "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}")

    # Compress manual
    add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz"
        COMMAND gzip "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}" --stdout > "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz"
        DEPENDS "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}"
        COMMENT "Generating ${DEV_FILE_NAME}.${DEV_CATEGORY}.gz"
        VERBATIM)
    add_custom_target(man ALL DEPENDS "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz")
    list(APPEND DEV_PACKAGE_TARGETS man)
endif()