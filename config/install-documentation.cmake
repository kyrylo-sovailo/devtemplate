#########################
# Install documentation #
#########################

install(DIRECTORY "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}-${DEV_MAJOR}.${DEV_MINOR}.${DEV_PATCH}"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/doc")