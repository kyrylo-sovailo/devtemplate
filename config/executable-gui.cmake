#########################
# Define GUI executable #
#########################

# Dependencies
if (NOT WIN32)
    find_package(X11 REQUIRED)
    find_package(PNG REQUIRED)
endif()

# Define executable
add_executable(${DEV_CMAKE_NAME}_executable_gui)
target_link_libraries(${DEV_CMAKE_NAME}_executable_gui PUBLIC ${DEV_CMAKE_NAME})
if (NOT WIN32)
    target_link_libraries(${DEV_CMAKE_NAME}_executable_gui PRIVATE X11::X11 PNG::PNG)
endif()

# Define executable sources
if (WIN32)
    target_sources(${DEV_CMAKE_NAME}_executable_gui PRIVATE "executable/executable-win32.cpp")
else()
    target_sources(${DEV_CMAKE_NAME}_executable_gui PRIVATE "executable/executable-x11.cpp")
endif()

# Define properties
set_target_properties(${DEV_CMAKE_NAME}_executable_gui PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}_executable_gui")

# Compile resource
if (WIN32)
    # Identify resource compiler
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

    # Compile resource
    if(DEV_RESOURCE_COMPILE)
        add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/executable-win32.${DEV_RESOURCE_EXTENSION}"
        COMMAND ${DEV_RESOURCE_COMPILE} ${DEV_RESOURCE_ARGUMENT}"${PROJECT_BINARY_DIR}/executable-win32.${DEV_RESOURCE_EXTENSION}" "${PROJECT_SOURCE_DIR}/executable/executable-win32.rc"
        DEPENDS "${PROJECT_SOURCE_DIR}/executable/executable-win32.rc"
        COMMENT "Compiling executable-win32.${DEV_RESOURCE_EXTENSION}")
        add_custom_target(${DEV_CMAKE_NAME}_executable_gui_res DEPENDS "${PROJECT_BINARY_DIR}/executable-win32.${DEV_RESOURCE_EXTENSION}")
    endif()

    # Add resource to target
    if (DEV_RESOURCE_COMPILE)
        add_dependencies(${DEV_CMAKE_NAME}_executable_gui ${DEV_CMAKE_NAME}_executable_gui_res)
        target_link_libraries(${DEV_CMAKE_NAME}_executable_gui PRIVATE "${PROJECT_BINARY_DIR}/executable-win32.${DEV_RESOURCE_EXTENSION}")
    endif()
endif()

# Set target type
if (WIN32)
    set_target_properties(${DEV_CMAKE_NAME}_executable_gui PROPERTIES WIN32_EXECUTABLE ON)
    target_compile_definitions(${DEV_CMAKE_NAME}_executable_gui PRIVATE DEV_WIN32_EXECUTABLE)
endif()

# Define "run_gui" command
add_custom_target(run_gui COMMAND ${DEV_CMAKE_NAME}_executable_gui)