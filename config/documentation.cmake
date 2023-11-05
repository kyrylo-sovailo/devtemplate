##########################
# Generate documentation #
##########################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME})
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}\" does not exist, cannot generate documentation")
endif()

# Generate Doxyfile
devtemplate_configure_file(${DEV_CMAKE_NAME}_doxyfile FALSE "${PROJECT_SOURCE_DIR}/config/template/Doxyfile" "${PROJECT_BINARY_DIR}/Doxyfile")

# Generate documentation.h
devtemplate_configure_file(${DEV_CMAKE_NAME}_documentation_header FALSE "${PROJECT_SOURCE_DIR}/config/template/documentation.h" "${PROJECT_BINARY_DIR}/documentation.h")

# Generate documentation ("doc" target)
find_package(Doxygen REQUIRED)
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}-${DEV_MAJOR}.${DEV_MINOR}.${DEV_PATCH}")
get_target_property(DEV_INTERFACE_SOURCES ${DEV_CMAKE_NAME} INTERFACE_SOURCES)
add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/documentation.stamp"
    COMMAND doxygen "${PROJECT_BINARY_DIR}/Doxyfile"
    COMMAND cmake -E touch "${PROJECT_BINARY_DIR}/documentation.stamp"
    DEPENDS "${PROJECT_BINARY_DIR}/Doxyfile" "${PROJECT_BINARY_DIR}/documentation.h" "${DEV_INTERFACE_SOURCES}"
    COMMENT "Generating documentation"
    VERBATIM)
add_custom_target(doc ALL DEPENDS "${PROJECT_BINARY_DIR}/documentation.stamp")
list(APPEND DEV_PACKAGE_TARGETS doc)
