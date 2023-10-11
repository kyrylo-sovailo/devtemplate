#########################
# Install CMake package #
#########################

# Dependencies
include(CMakePackageConfigHelpers)

# Install export set
install(EXPORT ${DEV_CMAKE_NAME}_export
    FILE "${DEV_FILE_NAME}Targets.cmake"
    NAMESPACE ${DEV_CMAKE_NAME}::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${DEV_CMAKE_NAME}")