###################################
# Install icons and desktop files #
###################################

# Update gui-environment.cmake
file(READ "${PROJECT_SOURCE_DIR}/config/template/gui.desktop" DEV_GUI)
if (EXISTS "${PROJECT_BINARY_DIR}/gui-environment.cmake")
    file(READ "${PROJECT_BINARY_DIR}/gui-environment.cmake" DEV_OLD_GUI_ENVIRONMENT)
endif()
get_cmake_property(DEV_VARIABLES VARIABLES)
set(DEV_GUI_ENVIRONMENT "")
foreach (DEV_VARIABLE ${DEV_VARIABLES})
    if ("${DEV_GUI}" MATCHES ".*${DEV_VARIABLE}.*")
        set(DEV_GUI_ENVIRONMENT "${DEV_GUI_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
    endif()
endforeach()
if (NOT "${DEV_GUI_ENVIRONMENT}" STREQUAL "${DEV_OLD_GUI_ENVIRONMENT}")
    file(WRITE "${PROJECT_BINARY_DIR}/gui-environment.cmake" "${DEV_GUI_ENVIRONMENT}")
endif()

# Generate gui.desktop
add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/gui.desktop"
    COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/script/configure.cmake" "${PROJECT_SOURCE_DIR}/config/template/gui.desktop" "${PROJECT_BINARY_DIR}/gui-environment.cmake" "${PROJECT_BINARY_DIR}/gui.desktop"
    DEPENDS "${PROJECT_SOURCE_DIR}/config/template/gui.desktop" "${PROJECT_BINARY_DIR}/gui-environment.cmake"
    COMMENT "Generating gui.desktop"
    VERBATIM)
add_custom_target(${DEV_FILE_NAME}_gui_desktop ALL DEPENDS "${PROJECT_BINARY_DIR}/gui.desktop")

# Install gui.desktop
install(FILES "${PROJECT_BINARY_DIR}/gui.desktop"
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