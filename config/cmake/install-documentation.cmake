#########################
# Install documentation #
#########################

# Dependencies
if (NOT TARGET doc)
    message(FATAL_ERROR "Target \"doc\" does not exist, cannot install documentation")
endif()

# Install documentation
install(DIRECTORY "${PROJECT_BINARY_DIR}/${DEV_DOCUMENTATION_NAME}"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/doc")

# Install changelog
if (DEV_DOCUMENTATION_CHANGELOG_NAME)
    install(FILES "${PROJECT_BINARY_DIR}/${DEV_DOCUMENTATION_CHANGELOG_NAME}"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/doc/${DEV_DOCUMENTATION_NAME}")
endif()

# Install copyright
if (DEV_DOCUMENTATION_COPYRIGHT_NAME)
    install(FILES "${PROJECT_BINARY_DIR}/${DEV_DOCUMENTATION_COPYRIGHT_NAME}"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/doc/${DEV_DOCUMENTATION_NAME}")
endif()

# Install readme
if (DEV_DOCUMENTATION_README_NAME)
    install(FILES "${PROJECT_BINARY_DIR}/${DEV_DOCUMENTATION_README_NAME}"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/doc/${DEV_DOCUMENTATION_NAME}")
endif()
