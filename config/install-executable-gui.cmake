###################################
# Install icons and desktop files #
###################################

if (NOT WIN32)
    # Dependencies
    if (NOT TARGET ${DEV_CMAKE_NAME}_executable_gui)
        message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}_executable_gui\" does not exist, cannot install graphical executable details")
    endif()
    
    # Generate gui.desktop
    devtemplate_configure_file(OUTPUT "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.desktop" INPUT "${PROJECT_SOURCE_DIR}/config/template/gui.desktop")
    list(APPEND DEV_PACKAGE_TARGETS "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.desktop")

    # Install gui.desktop
    install(FILES "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.desktop"
        RENAME "${DEV_FILE_NAME}_executable_gui.desktop"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/applications")

    # Install icons
    foreach(DEV_ICON_SIZE IN ITEMS 16 24 32 48 64 128 256)
        devtemplate_install_icon(INPUT_NAME "${DEV_ICON_SIZE}x${DEV_ICON_SIZE}.png"
            OUTPUT_NAME "${DEV_FILE_NAME}_executable_gui.png"
            DIRECTORY_NAME "${DEV_ICON_SIZE}x${DEV_ICON_SIZE}")
    endforeach()
    devtemplate_install_icon(INPUT_NAME "scalable.svg"
        OUTPUT_NAME "scalable"
        DIRECTORY_NAME "${DEV_FILE_NAME}_executable_gui.svg")
endif()