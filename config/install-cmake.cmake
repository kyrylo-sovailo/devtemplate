# Installing CMake description of the library
include(GNUInstallDirs)
install(EXPORT ${DEV_CMAKE_NAME}_targets
    FILE "${DEV_CMAKE_NAME}Targets.cmake"
    NAMESPACE ${DEV_CMAKE_NAME}::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${DEV_CMAKE_NAME}"
)