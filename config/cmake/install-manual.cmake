##################
# Install manual #
##################

if (DEV_MAN_NAME)
    # Dependencies
    if (NOT TARGET man)
        message(FATAL_ERROR "Target \"man\" does not exist, cannot install manual")
    endif()

    # Install manual
    install(FILES "${PROJECT_BINARY_DIR}/${DEV_MAN_NAME}"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/man/man${DEV_CATEGORY}")
endif()