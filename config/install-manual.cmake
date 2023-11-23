##################
# Install manual #
##################

if (NOT WIN32)
    # Dependencies
    if (NOT TARGET ${DEV_CMAKE_NAME})
        message(FATAL_ERROR "Target \"man\" does not exist, cannot install manual")
    endif()

    # Install manual
    install(FILES "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.${DEV_CATEGORY}.gz"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/man/man${DEV_CATEGORY}")
endif()