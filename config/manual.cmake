###################
# Generate manual #
###################

# Generate manual
devtemplate_configure_file(OUTPUT "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}" INPUT "${PROJECT_SOURCE_DIR}/config/template/man.1")

# Compress manual ("man" target)
add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz"
    COMMAND gzip "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}" --stdout > "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz"
    DEPENDS "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}"
    COMMENT "Generating ${DEV_FILE_NAME}.${DEV_CATEGORY}.gz")
if (NOT WIN32)
    add_custom_target(man ALL DEPENDS "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz")
    list(APPEND DEV_PACKAGE_TARGETS man)
else()
    add_custom_target(man DEPENDS "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz")
endif()