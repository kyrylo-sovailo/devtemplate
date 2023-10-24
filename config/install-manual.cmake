##################
# Install manual #
##################

install(FILES "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/man/man${DEV_CATEGORY}")