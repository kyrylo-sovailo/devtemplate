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
    add_compile_options(/wd4625) #C4625: Copy constructor was implicitly defined as deleted
    add_compile_options(/wd4626) #C4626: Assignment operator was implicitly defined as deleted
    add_compile_options(/wd4710) #C4710: Function not inlined
    add_compile_options(/wd4711) #C4711: Selected for automatic inline expansion
    add_compile_options(/wd4820) #C4820: N bytes padding added after data member
    add_compile_options(/wd4868) #C4868: Compiler may not enforce left-to-right evaluation order in braced initializer list
    add_compile_options(/wd5039) #C5039: Pointer or reference to potentially throwing function passed to 'extern "C"
    add_compile_options(/wd5045) #C5045: Compiler will insert Spectre mitigation for memory
elseif ("${DEV_COMPILER_STYLE}" STREQUAL "GNU")
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# Linker flags
if ("${DEV_COMPILER}" STREQUAL "MSVC")
    add_link_options(/MANIFEST:NO)
endif()

# Resource compilation
if (WIN32)
    if("${DEV_COMPILER}" STREQUAL "MSVC")
        set(DEV_RESOURCE_COMPILE "DEFAULT")
        #set(DEV_RESOURCE_COMPILE "rc")
        #set(DEV_RESOURCE_OUTPUT "/fo ")
        #set(DEV_RESOURCE_EXTENSION "res")
    elseif("${DEV_COMPILER}" STREQUAL "GNU")
        set(DEV_RESOURCE_COMPILE "windres -O coff")
        set(DEV_RESOURCE_OUTPUT "--output=")
        set(DEV_RESOURCE_EXTENSION "o")
    elseif("${DEV_COMPILER}" STREQUAL "Clang")
        set(DEV_RESOURCE_COMPILE "DEFAULT")
        #set(DEV_RESOURCE_COMPILE "llvm-rc")
        #set(DEV_RESOURCE_OUTPUT "/fo ")
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

# Check if file exist
function(devtemplate_check_file DEV_VAR DEV_PATH)
    if (IS_ABSOLUTE "${DEV_PATH}")
        set(DEV_ABSOLUTE_PATH "${DEV_PATH}")
    else()
        get_filename_component(DEV_ABSOLUTE_PATH "${DEV_PATH}" ABSOLUTE BASE_DIR "${PROJECT_SOURCE_DIR}")
    endif()
    if (NOT EXISTS "${DEV_ABSOLUTE_PATH}")
        message(FATAL_ERROR "${DEV_PATH} does not exist")
    endif()
    set(${DEV_VAR} "${DEV_ABSOLUTE_PATH}" PARENT_SCOPE)
endfunction()

# Replaces relative paths in target's property with absolute paths
function(devtemplate_make_absolute)
    # Parse arguments
    cmake_parse_arguments(DEV "" "TARGET;PROPERTY" "" ${ARGN})
    if (DEV_UNPARSED_ARGUMENTS OR NOT DEV_TARGET OR NOT DEV_PROPERTY)
        message(FATAL_ERROR "devtemplate_make_absolute called with incorrect arguments")
    endif()
    # Expand paths
    get_target_property(DEV_PATHS ${DEV_TARGET} ${DEV_PROPERTY})
    foreach(DEV_PATH IN LISTS DEV_PATHS)
        file(RELATIVE_PATH DEV_RELATIVE_PATH "${PROJECT_SOURCE_DIR}" "${DEV_PATH}")
        list(APPEND DEV_EXPANDED_PATHS "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${DEV_RELATIVE_PATH}>$<INSTALL_INTERFACE:${DEV_RELATIVE_PATH}>")
    endforeach()
    set_target_properties(${DEV_TARGET} PROPERTIES ${DEV_PROPERTY} "${DEV_EXPANDED_PATHS}")
endfunction()

# Checks the environment and configures file if needed
function(devtemplate_configure_file)
    # Parse arguments
    cmake_parse_arguments(DEV "" "INPUT;OUTPUT" "" ${ARGN})
    if (DEV_UNPARSED_ARGUMENTS OR NOT DEV_INPUT OR NOT DEV_OUTPUT)
        message(FATAL_ERROR "devtemplate_configure_file called with incorrect arguments")
    endif()
    devtemplate_check_file(DEV_INPUT "${DEV_INPUT}")
    get_filename_component(DEV_OUTPUT "${DEV_OUTPUT}" ABSOLUTE)
    get_filename_component(DEV_OUTPUT_NAME "${DEV_OUTPUT}" NAME)
    # Read input file
    file(READ "${DEV_INPUT}" DEV_INPUT_FILE)
    # Read environment file
    if (EXISTS "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake")
        file(READ "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake" DEV_OLD_ENVIRONMENT)
    else()
        set(DEV_OLD_ENVIRONMENT)
    endif()
    # Compose new environment
    get_cmake_property(DEV_VARIABLES VARIABLES)
    set(DEV_ENVIRONMENT)
    foreach (DEV_VARIABLE IN LISTS DEV_VARIABLES)
        if ("${DEV_INPUT_FILE}" MATCHES "^.*(\\\${${DEV_VARIABLE}}|\\\$${DEV_VARIABLE}|@${DEV_VARIABLE}@).*$")
            set(DEV_ENVIRONMENT "${DEV_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
        endif()
    endforeach()
    # Compare environments and rewrite if needed
    if (NOT "${DEV_ENVIRONMENT}" STREQUAL "${DEV_OLD_ENVIRONMENT}")
        file(WRITE "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake" "${DEV_ENVIRONMENT}")
    elseif(NOT EXISTS "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake")
        file(WRITE "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake")
    endif()
    # Define rule
    add_custom_command(OUTPUT "${DEV_OUTPUT}"
        COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/script/configure.cmake" "${DEV_INPUT}" "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake" "${DEV_OUTPUT}"
        DEPENDS "${DEV_INPUT}" "${PROJECT_BINARY_DIR}/environment/${DEV_OUTPUT_NAME}.cmake"
        COMMENT "Generating ${DEV_OUTPUT_NAME}")
endfunction()

# Compiles and links resource
function(devtemplate_target_resource)
    # Parse arguments
    cmake_parse_arguments(DEV "" "TARGET;INPUT" "DEPENDS" ${ARGN})
    if (DEV_UNPARSED_ARGUMENTS OR NOT DEV_TARGET OR NOT DEV_INPUT)
        message(FATAL_ERROR "devtemplate_target_resource called with incorrect arguments")
    endif()
    devtemplate_check_file(DEV_INPUT "${DEV_INPUT}")
    get_filename_component(DEV_INPUT_NAME "${DEV_INPUT}" NAME)
    foreach(DEV_DEPEND ${DEV_DEPENDS})
        if (NOT IS_ABSOLUTE "${DEV_DEPEND}")
            get_filename_component(DEV_DEPEND "${DEV_DEPEND}" ABSOLUTE BASE_DIR "${PROJECT_SOURCE_DIR}")
        endif()
        list(APPEND DEV_DEPENDS_ABSOLUTE "${DEV_DEPEND}")
    endforeach()
    # Compiler can compile resources directly
    if (DEV_RESOURCE_COMPILE AND "${DEV_RESOURCE_COMPILE}" STREQUAL "DEFAULT")
        target_sources(${DEV_TARGET} PRIVATE "${DEV_INPUT}")
        add_custom_target(${DEV_TARGET}_resources DEPENDS "${DEV_DEPENDS_ABSOLUTE}")
        add_dependencies(${DEV_TARGET} ${DEV_TARGET}_resources)
    # Compiler cannot compile resources directly
    elseif (DEV_RESOURCE_COMPILE)
        add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/${DEV_INPUT_NAME}.${DEV_RESOURCE_EXTENSION}"
            COMMAND ${DEV_RESOURCE_COMPILE} ${DEV_RESOURCE_OUTPUT}"${PROJECT_BINARY_DIR}/${DEV_INPUT_NAME}.${DEV_RESOURCE_EXTENSION}" "${DEV_INPUT}"
            WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
            DEPENDS "${DEV_INPUT}" "${DEV_DEPENDS_ABSOLUTE}"
            COMMENT "Compiling ${DEV_INPUT_NAME}")
        target_link_libraries(${DEV_TARGET} PRIVATE "${PROJECT_BINARY_DIR}/${DEV_INPUT_NAME}.${DEV_RESOURCE_EXTENSION}")
    endif()
endfunction()

# Installs icon file
function(devtemplate_install_icon DEV_INPUT_FILE_NAME DEV_OUTPUT_DIR_NAME DEV_OUTPUT_FILE_NAME)
    # Parse arguments
    cmake_parse_arguments(DEV "" "INPUT_NAME;OUTPUT_NAME;DIRECTORY_NAME" "" ${ARGN})
    if (DEV_UNPARSED_ARGUMENTS OR NOT DEV_INPUT_NAME OR NOT DEV_OUTPUT_NAME OR NOT DEV_DIRECTORY_NAME)
        message(FATAL_ERROR "devtemplate_install_icon called with incorrect arguments")
    elseif(NOT EXISTS "${PROJECT_SOURCE_DIR}/icons/${DEV_INPUT_NAME}")
        message(FATAL_ERROR "${PROJECT_SOURCE_DIR}/icons/${DEV_INPUT_NAME} does not exist") #TODO: make more cmake similar
    endif()
    # Install
    install(FILES "${PROJECT_SOURCE_DIR}/icons/${DEV_INPUT_NAME}"
        RENAME "${DEV_OUTPUT_NAME}"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/${DEV_DIRECTORY_NAME}/apps")
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
