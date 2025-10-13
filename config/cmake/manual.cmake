###################
# Generate manual #
###################

# Generate manual
if (DEV_MAN_NAME)
    devtemplate_configure_compress(${DEV_CMAKE_NAME}_manual_raw man "${PROJECT_SOURCE_DIR}/config/template/man.1" "${PROJECT_BINARY_DIR}/${DEV_MAN_NAME}")
    list(APPEND DEV_CORE_TARGETS man)
endif()
