#########################
# Install documentation #
#########################

# Dependencies
if (NOT TARGET doc)
    message(FATAL_ERROR "Target \"doc\" does not exist, cannot install documentation")
endif()

# Install
install(DIRECTORY "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}-${DEV_MAJOR}.${DEV_MINOR}.${DEV_PATCH}"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/doc")
