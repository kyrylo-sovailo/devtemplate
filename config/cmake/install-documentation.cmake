#########################
# Install documentation #
#########################

# Dependencies
if (NOT TARGET doc)
    message(FATAL_ERROR "Target \"doc\" does not exist, cannot install documentation")
endif()

# Install documentation
install(DIRECTORY "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/doc")

# Install changelog
if (UNIX)
    install(FILES "${PROJECT_BINARY_DIR}/changelog.gz"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/doc/${DEV_FILE_NAME}")
endif()

# Install copyright
install(FILES "${PROJECT_BINARY_DIR}/copyright"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/doc/${DEV_FILE_NAME}")
