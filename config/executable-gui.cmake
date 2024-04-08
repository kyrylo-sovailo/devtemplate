#########################
# Define GUI executable #
#########################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME})
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}\" does not exist, cannot create graphical executable")
endif()

# Define executable
add_executable(${DEV_CMAKE_NAME}_executable_gui)
list(APPEND DEV_EXPORT_TARGETS ${DEV_CMAKE_NAME}_executable_gui)
list(APPEND DEV_PACKAGE_TARGETS ${DEV_CMAKE_NAME}_executable_gui)
set_target_properties(${DEV_CMAKE_NAME}_executable_gui PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}-executable-gui$<$<CONFIG:Debug>:-debug>")
if (WIN32)
    set_target_properties(${DEV_CMAKE_NAME}_executable_gui PROPERTIES WIN32_EXECUTABLE ON)
    target_compile_definitions(${DEV_CMAKE_NAME}_executable_gui PRIVATE DEV_WIN32_EXECUTABLE)
endif()

# Link dependencies
target_link_libraries(${DEV_CMAKE_NAME}_executable_gui PRIVATE ${DEV_CMAKE_NAME})
if (NOT WIN32)
    find_package(X11 REQUIRED)
    find_package(PNG REQUIRED)
    if (${DEV_CMAKE_MAJOR} GREATER 3 OR (${DEV_CMAKE_MAJOR} EQUAL 3 AND ${DEV_CMAKE_MINOR} GREATER_EQUAL 14))
        target_link_libraries(${DEV_CMAKE_NAME}_executable_gui PRIVATE X11::X11 PNG::PNG)
    else()
        target_compile_definitions(${DEV_CMAKE_NAME}_executable_gui PRIVATE ${PNG_DEFINITIONS})
        target_include_directories(${DEV_CMAKE_NAME}_executable_gui PRIVATE ${X11_INCLUDE_DIR} ${PNG_INCLUDE_DIRS})
        target_link_libraries(${DEV_CMAKE_NAME}_executable_gui PRIVATE ${X11_LIBRARIES} ${PNG_LIBRARIES})
    endif()
endif()

# Link resources
if (WIN32)
    devtemplate_configure_file(TARGET ${DEV_CMAKE_NAME}_executable_gui_manifest
        INPUT "${PROJECT_SOURCE_DIR}/config/template/executable.manifest"
        OUTPUT "${PROJECT_BINARY_DIR}/executable.manifest")
    devtemplate_compile_resource(TARGET ${DEV_CMAKE_NAME}_executable_gui
        RESOURCE_TARGET ${DEV_CMAKE_NAME}_executable_gui_resource
        INPUT "executable/executable-win32.rc"
        DEPENDS ${DEV_CMAKE_NAME}_executable_gui_manifest)
endif()

# Define sources
target_sources(${DEV_CMAKE_NAME}_executable_gui PRIVATE "executable/executable-win32.cpp")

# Define "run_gui" command
add_custom_target(run_gui COMMAND ${DEV_CMAKE_NAME}_executable_gui)
