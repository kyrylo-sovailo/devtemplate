############################
# Export CMake description #
############################

# Dependencies
if (NOT ${DEV_CMAKE_NAME}_export)
    message(FATAL_ERROR "Export \"${DEV_CMAKE_NAME}_export\" does not exist, cannot export library")
endif()

# Exporting library
export(EXPORT ${DEV_CMAKE_NAME}_export
    NAMESPACE ${DEV_CMAKE_NAME}::
    FILE "${PROJECT_SOURCE_DIR}/${DEV_CMAKE_NAME}Config.cmake")
