# Exporting library
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}_targets)
export(EXPORT ${PROJECT_NAME}_targets
    FILE "${PROJECT_BINARY_DIR}/{PROJECT_NAME}Targets.cmake"
    NAMESPACE ${PROJECT_NAME}::)
configure_package_config_file("${PROJECT_SOURCE_DIR}/config/misc/config.cmake.in"
    "${PROJECT_SOURCE_DIR}/${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}")
write_basic_package_version_file("${PROJECT_SOURCE_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion)