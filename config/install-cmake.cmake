# Installing CMake description of the library
include(GNUInstallDirs)
install(EXPORT ${PROJECT_NAME}_targets
    FILE "${PROJECT_NAME}Targets.cmake"
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
)