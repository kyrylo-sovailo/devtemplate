# Defining GUI executable
if (WIN32)
    # Identifying resource compiler
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        set(DEV_RESOURCE_COMPILE "rc")
        set(DEV_RESOURCE_ARGUMENT "/fo ")
        set(DEV_RESOURCE_EXTENSION "res")
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        set(DEV_RESOURCE_COMPILE "windres")
        set(DEV_RESOURCE_ARGUMENT "--output=")
        set(DEV_RESOURCE_EXTENSION "o")
    else()
        message(WARNING "The compiler (${CMAKE_CXX_COMPILER_ID}) is not supported, compiling Windows application without icons")
    endif()

    # Compiling resource
    if(DEV_RESOURCE_COMPILE)
        add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/executable-win32.${DEV_RESOURCE_EXTENSION}"
        COMMAND ${DEV_RESOURCE_COMPILE} ${DEV_RESOURCE_ARGUMENT}"${PROJECT_BINARY_DIR}/executable-win32.${DEV_RESOURCE_EXTENSION}" "${PROJECT_SOURCE_DIR}/executable/executable-win32.rc"
        DEPENDS "${PROJECT_SOURCE_DIR}/executable/executable-win32.rc"
        COMMENT "Compiling executable-win32.${DEV_RESOURCE_EXTENSION}")
        add_custom_target(${PROJECT_NAME}_executable_gui_res DEPENDS "${PROJECT_BINARY_DIR}/executable-win32.${DEV_RESOURCE_EXTENSION}")
    endif()

    # Compiling executable
    add_executable(${PROJECT_NAME}_executable_gui WIN32)
    target_sources(${PROJECT_NAME}_executable_gui PRIVATE "executable/executable-win32.cpp")
    if (DEV_RESOURCE_COMPILE)
        add_dependencies(${PROJECT_NAME}_executable_gui ${PROJECT_NAME}_executable_gui_res)
        target_link_libraries(${PROJECT_NAME}_executable_gui PRIVATE "${PROJECT_BINARY_DIR}/executable-win32.${DEV_RESOURCE_EXTENSION}")
    endif()
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
add_custom_target(run_gui COMMAND ${PROJECT_NAME}_executable_gui)