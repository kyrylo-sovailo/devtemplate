###################################
# Install icons and desktop files #
###################################

# Generate gui.desktop
devtemplate_configure_file(${DEV_CMAKE_NAME}_gui_desktop TRUE "${PROJECT_SOURCE_DIR}/config/template/gui.desktop" "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.desktop")

# Install gui.desktop
install(FILES "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}.desktop"
    RENAME "${DEV_FILE_NAME}_executable_gui.desktop"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/applications")

# Install icons
foreach(DEV_ICON_SIZE 16 24 32 48 64 128 256)
    devtemplate_install_icon("${DEV_ICON_SIZE}x${DEV_ICON_SIZE}.png" "${DEV_ICON_SIZE}x${DEV_ICON_SIZE}" "${DEV_FILE_NAME}_executable_gui.png")
endforeach()
devtemplate_install_icon("scalable.svg" "scalable" "${DEV_FILE_NAME}_executable_gui.svg")