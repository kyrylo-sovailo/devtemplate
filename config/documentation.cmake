##########################
# Generate documentation #
##########################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME})
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}\" does not exist, cannot generate documentation")
endif()
find_package(Doxygen REQUIRED)

# Generate mainpage.h
devtemplate_configure_file(INPUT "${PROJECT_SOURCE_DIR}/config/template/mainpage.h" OUTPUT "${PROJECT_BINARY_DIR}/mainpage.h")
add_custom_target(${DEV_CMAKE_NAME}_mainpage DEPENDS "${PROJECT_BINARY_DIR}/mainpage.h")
add_dependencies(${DEV_CMAKE_NAME} ${DEV_CMAKE_NAME}_mainpage)

# Generate Doxyfile
devtemplate_configure_file(INPUT "${PROJECT_SOURCE_DIR}/config/template/Doxyfile" OUTPUT "${PROJECT_BINARY_DIR}/Doxyfile")

# Generate documentation ("doc" target)
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/${DEV_FILE_NAME}-${DEV_MAJOR}.${DEV_MINOR}.${DEV_PATCH}")
get_target_property(DEV_INTERFACE_SOURCES ${DEV_CMAKE_NAME} INTERFACE_SOURCES)
add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/documentation.stamp"
    COMMAND doxygen "${PROJECT_BINARY_DIR}/Doxyfile"
    COMMAND cmake -E touch "${PROJECT_BINARY_DIR}/documentation.stamp"
    DEPENDS "${DEV_INTERFACE_SOURCES}" ${DEV_CMAKE_NAME}_mainpage "${PROJECT_BINARY_DIR}/mainpage.h" "${PROJECT_BINARY_DIR}/Doxyfile"
    COMMENT "Generating documentation")
add_custom_target(doc ALL DEPENDS "${PROJECT_BINARY_DIR}/documentation.stamp")
list(APPEND DEV_PACKAGE_TARGETS doc)
