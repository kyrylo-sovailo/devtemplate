# Exporting library
export(EXPORT ${DEV_CMAKE_NAME}_export
    NAMESPACE ${DEV_CMAKE_NAME}::
    FILE "${PROJECT_SOURCE_DIR}/${DEV_CMAKE_NAME}Config.cmake")