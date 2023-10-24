#############################
# Install CMake description #
#############################

# Dependencies
include(CMakePackageConfigHelpers)

# Install export set
install(EXPORT ${DEV_CMAKE_NAME}_export
    FILE "${DEV_FILE_NAME}Targets.cmake"
    NAMESPACE ${DEV_CMAKE_NAME}::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${DEV_CMAKE_NAME}")

# Generate config file
configure_package_config_file("${PROJECT_SOURCE_DIR}/config/template/config.cmake.in"
    "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}Config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${DEV_FILE_NAME}")

# Generate version file
write_basic_package_version_file("${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}ConfigVersion.cmake"
    COMPATIBILITY SameMajorVersion)

# Install configuration files
install(FILES "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}Config.cmake"
    "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}ConfigVersion.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${DEV_FILE_NAME}")