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
install(FILES "${PROJECT_SOURCE_DIR}/icon/16x16.png"
    RENAME "${DEV_FILE_NAME}_executable_gui.png"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/16x16/apps")
install(FILES "${PROJECT_SOURCE_DIR}/icon/24x24.png"
    RENAME "${DEV_FILE_NAME}_executable_gui.png"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/24x24/apps")
install(FILES "${PROJECT_SOURCE_DIR}/icon/32x32.png"
    RENAME "${DEV_FILE_NAME}_executable_gui.png"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/32x32/apps")
install(FILES "${PROJECT_SOURCE_DIR}/icon/48x48.png"
    RENAME "${DEV_FILE_NAME}_executable_gui.png"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/48x48/apps")
install(FILES "${PROJECT_SOURCE_DIR}/icon/64x64.png"
    RENAME "${DEV_FILE_NAME}_executable_gui.png"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/64x64/apps")
install(FILES "${PROJECT_SOURCE_DIR}/icon/128x128.png"
    RENAME "${DEV_FILE_NAME}_executable_gui.png"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/128x128/apps")
install(FILES "${PROJECT_SOURCE_DIR}/icon/256x256.png"
    RENAME "${DEV_FILE_NAME}_executable_gui.png"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/256x256/apps")
install(FILES "${PROJECT_SOURCE_DIR}/icon/scalable.svg"
    RENAME "${DEV_FILE_NAME}_executable_gui.svg"
    DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps")