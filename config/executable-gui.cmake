# Defining GUI executable
if (WIN32)
    # Compiling resources
    add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/executable-win32.res"
    COMMAND rc /fo "${PROJECT_BINARY_DIR}/executable-win32.res" "executable/executable-win32.rc"
    WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
    DEPENDS "executable/executable-win32.rc"
    COMMENT "Compiling executable-win32.res")
    add_custom_target(${PROJECT_NAME}_executable_gui_res DEPENDS "${PROJECT_BINARY_DIR}/executable-win32.res")

    # Compiling executable
    add_executable(${PROJECT_NAME}_executable_gui WIN32)
    add_dependencies(${PROJECT_NAME}_executable_gui ${PROJECT_NAME}_executable_gui_res)
    target_sources(${PROJECT_NAME}_executable_gui PRIVATE "executable/executable-win32.cpp")
    target_link_libraries(${PROJECT_NAME}_executable_gui PRIVATE "${PROJECT_BINARY_DIR}/executable-win32.res")
    get_target_property(WIN32_EXECUTABLE ${PROJECT_NAME}_executable_gui WIN32_EXECUTABLE)
    if(WIN32_EXECUTABLE)
        target_compile_definitions(${PROJECT_NAME}_executable_gui PRIVATE WIN32_EXECUTABLE)
    endif()
else()
    # Compiling executable
    add_executable(${PROJECT_NAME}_executable_gui)
    target_sources(${PROJECT_NAME}_executable_gui PRIVATE "executable/executable-x11.cpp")
    find_package(X11 REQUIRED)
    target_link_libraries(${PROJECT_NAME}_executable_gui PRIVATE X11)
endif()
target_link_libraries(${PROJECT_NAME}_executable_gui PUBLIC ${PROJECT_NAME})