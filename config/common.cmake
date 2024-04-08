########################
# Common functionality #
########################

# Dependencies
include(GNUInstallDirs)

# Global variables
unset(DEV_EXPORT_TARGETS)    #List of targets that should be exported via CMake file
unset(DEV_PACKAGE_TARGETS)   #List of all targets that should be made before packaging

# CMake version
execute_process(COMMAND "${CMAKE_COMMAND}" --version OUTPUT_VARIABLE DEV_CMAKE_VERSION ERROR_VARIABLE DEV_CMAKE_VERSION_ERROR RESULT_VARIABLE DEV_CMAKE_VERSION_RESULT)
string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" DEV_CMAKE_VERSION "${DEV_CMAKE_VERSION}")
if ("${DEV_CMAKE_VERSION}" STREQUAL "" OR NOT "${DEV_CMAKE_VERSION_ERROR}" STREQUAL "" OR NOT ${DEV_CMAKE_VERSION_RESULT} EQUAL 0)
    message(FATAL_ERROR "Cannot check CMake version")
endif()
string(REPLACE "\." ";" DEV_CMAKE_VERSION "${DEV_CMAKE_VERSION}")
list(GET DEV_CMAKE_VERSION 0 DEV_CMAKE_MAJOR)
list(GET DEV_CMAKE_VERSION 1 DEV_CMAKE_MINOR)
list(GET DEV_CMAKE_VERSION 2 DEV_CMAKE_PATCH)

# Compiler identification
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    set(DEV_COMPILER "MSVC")
    set(DEV_COMPILER_STYLE "MSVC")
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    set(DEV_COMPILER "GNU")
    set(DEV_COMPILER_STYLE "GNU")
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    set(DEV_COMPILER "Clang")
    if ("${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}" STREQUAL "MSVC")
        set(DEV_COMPILER_STYLE "MSVC")
    else()
        set(DEV_COMPILER_STYLE "GNU")
    endif()
else()
    set(DEV_COMPILER "${CMAKE_CXX_COMPILER_ID}")
    set(DEV_COMPILER_STYLE "${CMAKE_CXX_COMPILER_ID}")
endif()

# Compiler flags
if ("${DEV_COMPILER_STYLE}" STREQUAL "MSVC")
    add_compile_options(/Wall)
    add_compile_options(/wd4668) #C4668: Macro is not defined as a preprocessor macro
    add_compile_options(/wd4710) #C4710: Function not inlined
    add_compile_options(/wd4711) #C4711: Selected for automatic inline expansion
    add_compile_options(/wd5045) #C5045: Compiler will insert Spectre mitigation for memory
elseif ("${DEV_COMPILER_STYLE}" STREQUAL "GNU")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Resource compilation
if (WIN32)
    if("${DEV_COMPILER}" STREQUAL "MSVC")
        set(DEV_RESOURCE_COMPILE "DEFAULT")
        #set(DEV_RESOURCE_COMPILE "rc")
        #set(DEV_RESOURCE_ARGUMENT "/fo ")
        #set(DEV_RESOURCE_EXTENSION "res")
    elseif("${DEV_COMPILER}" STREQUAL "GNU")
        set(DEV_RESOURCE_COMPILE "windres")
        set(DEV_RESOURCE_ARGUMENT "--output=")
        set(DEV_RESOURCE_EXTENSION "o")
    elseif("${DEV_COMPILER}" STREQUAL "Clang")
        set(DEV_RESOURCE_COMPILE "DEFAULT")
        #set(DEV_RESOURCE_COMPILE "llvm-rc")
        #set(DEV_RESOURCE_ARGUMENT "/fo ")
        #set(DEV_RESOURCE_EXTENSION "res")
    else()
        message(WARNING "The compiler (${DEV_COMPILER}) is not supported, cannot compile resource")
    endif()
endif()

# CRT forcing (This section is sponsored by some smarty pants from Google)
if (WIN32 AND DEV_FORCE_CRT)
    if (DEV_FORCE_CRT STREQUAL "static_release")
        add_compile_definitions(_ITERATOR_DEBUG_LEVEL=0)
        if ("${DEV_COMPILER_STYLE}" STREQUAL "MSVC")
            add_compile_options(/MT)
        endif()
    elseif (DEV_FORCE_CRT STREQUAL "dynamic_release")
        add_compile_definitions(_ITERATOR_DEBUG_LEVEL=0)
        if ("${DEV_COMPILER_STYLE}" STREQUAL "MSVC")
            add_compile_options(/MD)
        endif()
    elseif (DEV_FORCE_CRT STREQUAL "static_debug")
        if ("${DEV_COMPILER_STYLE}" STREQUAL "MSVC")
            add_compile_options(/MTd)
        endif()
    elseif (DEV_FORCE_CRT STREQUAL "dynamic_debug")
        if ("${DEV_COMPILER_STYLE}" STREQUAL "MSVC")
            add_compile_options(/MDd)
        endif()
    else()
        message(FATAL_ERROR "Invalid DEV_FORCE_CRT")
    endif()
endif()

# Replaces relative paths in target's property with absolute paths
function(devtemplate_make_absolute DEV_TARGET DEV_PROPERTY)
    get_target_property(DEV_PATHS ${DEV_TARGET} ${DEV_PROPERTY})
    foreach(DEV_PATH IN LISTS DEV_PATHS)
        file(RELATIVE_PATH DEV_RELATIVE_PATH "${PROJECT_SOURCE_DIR}" "${DEV_PATH}")
        list(APPEND DEV_RELATIVE_PATHS "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${DEV_RELATIVE_PATH}>$<INSTALL_INTERFACE:${DEV_RELATIVE_PATH}>")
    endforeach()
    set_target_properties(${DEV_TARGET} PROPERTIES ${DEV_PROPERTY} "${DEV_RELATIVE_PATHS}")
endfunction()

# Checks the environment and configures file if needed
function(devtemplate_configure_file DEV_TARGET_NAME DEV_ALL DEV_INPUT_PATH DEV_OUTPUT_PATH)
    get_filename_component(DEV_OUTPUT_NAME "${DEV_OUTPUT_PATH}" NAME)

    file(READ "${DEV_INPUT_PATH}" DEV_INPUT)
    if (EXISTS "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake")
        file(READ "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake" DEV_OLD_ENVIRONMENT)
    else()
        set(DEV_OLD_ENVIRONMENT)
    endif()
    get_cmake_property(DEV_VARIABLES VARIABLES)
    set(DEV_ENVIRONMENT)
    foreach (DEV_VARIABLE IN LISTS DEV_VARIABLES)
        if ("${DEV_INPUT}" MATCHES "^.*(\\\${${DEV_VARIABLE}}|\\\$${DEV_VARIABLE}|@${DEV_VARIABLE}@).*$")
            set(DEV_ENVIRONMENT "${DEV_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
        endif()
    endforeach()
    if (NOT "${DEV_ENVIRONMENT}" STREQUAL "${DEV_OLD_ENVIRONMENT}")
        file(WRITE "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake" "${DEV_ENVIRONMENT}")
    elseif(NOT EXISTS "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake")
        file(WRITE "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake")
    endif()
    
    add_custom_command(OUTPUT "${DEV_OUTPUT_PATH}"
        COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/script/configure.cmake" "${DEV_INPUT_PATH}" "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake" "${DEV_OUTPUT_PATH}"
        DEPENDS "${DEV_INPUT_PATH}" "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake"
        COMMENT "Generating ${DEV_OUTPUT_NAME}"
        VERBATIM)
    if (DEV_ALL)
        set(DEV_ALL "ALL")
    else()
        set(DEV_ALL "")
    endif()
    add_custom_target(${DEV_TARGET_NAME} ${DEV_ALL} DEPENDS "${DEV_OUTPUT_PATH}")
endfunction()

# Compiles and links resource
function(devtemplate_compile_resource DEV_TARGET_NAME DEV_RESOURCE_TARGET_NAME DEV_RESOURCE_PATH DEV_DEPENDENCIES)
    get_filename_component(DEV_RESOURCE_PATH "${DEV_RESOURCE_PATH}" ABSOLUTE)
        
    if (DEV_RESOURCE_COMPILE AND "${DEV_RESOURCE_COMPILE}" STREQUAL "DEFAULT")
        target_sources(${DEV_TARGET_NAME} PRIVATE "${DEV_RESOURCE_PATH}")
        if (DEV_DEPENDENCIES)
            add_dependencies(${DEV_TARGET_NAME} ${DEV_DEPENDENCIES})
        endif()
    elseif (DEV_RESOURCE_COMPILE)
        get_filename_component(DEV_RESOURCE_NAME "${DEV_RESOURCE_PATH}" NAME)
        
        add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/${DEV_RESOURCE_TARGET_NAME}.${DEV_RESOURCE_EXTENSION}"
        COMMAND ${DEV_RESOURCE_COMPILE} ${DEV_RESOURCE_ARGUMENT}"${PROJECT_BINARY_DIR}/${DEV_RESOURCE_TARGET_NAME}.${DEV_RESOURCE_EXTENSION}" "${DEV_RESOURCE_PATH}"
        WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
        DEPENDS "${DEV_RESOURCE_PATH}"
        COMMENT "Compiling ${DEV_RESOURCE_NAME}")
        add_custom_target(${DEV_RESOURCE_TARGET_NAME} DEPENDS "${PROJECT_BINARY_DIR}/${DEV_RESOURCE_TARGET_NAME}.${DEV_RESOURCE_EXTENSION}")
        add_dependencies(${DEV_RESOURCE_TARGET_NAME} ${DEV_DEPENDENCIES})
        
        target_link_libraries(${DEV_TARGET_NAME} PRIVATE "${PROJECT_BINARY_DIR}/${DEV_RESOURCE_TARGET_NAME}.${DEV_RESOURCE_EXTENSION}")
        if (DEV_DEPENDENCIES)
            add_dependencies(${DEV_TARGET_NAME} ${DEV_RESOURCE_TARGET_NAME})
        endif()
    endif()
endfunction()

# Installs icon file
function(devtemplate_install_icon DEV_INPUT_FILE_NAME DEV_OUTPUT_DIR_NAME DEV_OUTPUT_FILE_NAME)
    install(FILES "${PROJECT_SOURCE_DIR}/icons/${DEV_INPUT_FILE_NAME}"
        RENAME "${DEV_OUTPUT_FILE_NAME}"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/${DEV_OUTPUT_DIR_NAME}/apps")
endfunction()

# Unsets all variables used by Devtemplate
function(devtemplate_cleanup)
    get_cmake_property(DEV_VARIABLES VARIABLES)
    foreach (DEV_VARIABLE IN LISTS DEV_VARIABLES)
        if ("${DEV_VARIABLE}" MATCHES "^DEV_.+&" AND (NOT "${DEV_VARIABLE}" STREQUAL "DEV_VARIABLE") AND (NOT "${DEV_VARIABLE}" STREQUAL "DEV_VARIABLES"))
            unset(${DEV_VARIABLE} PARENT_SCOPE)
        endif()
    endforeach()
    unset(DEV_VARIABLE PARENT_SCOPE)
    unset(DEV_VARIABLS PARENT_SCOPE)
endfunction()
