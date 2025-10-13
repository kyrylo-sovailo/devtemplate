########################
# Common functionality #
########################

# Dependencies
include(GNUInstallDirs)

# Global variables
unset(DEV_EXPORT_TARGETS)   #List of targets that should be exported via CMake file
unset(DEV_CORE_TARGETS)     #List of all targets that should be made before packaging

# Flavors
# These switches control the behavior of generic .cmake files, they don't affect whether the distribution-specific files are generated
# DEV_DOCUMENTATION_NAME            - name of documentation folder
# DEV_DOCUMENTATION_CHANGELOG_NAME  - name of changelog file in doc (empty for none)
# DEV_DOCUMENTATION_COPYRIGHT_NAME  - name of copyright file in doc (empty for none)
# DEV_DOCUMENTATION_README_NAME     - name of readme file in doc (empty for none)
# DEV_MAN_NAME                      - name of man file in man (empty for none)
if(NOT DEFINED DEV_DEFAULT_FLAVOR)
    if(WIN32)
        set(DEV_DEFAULT_FLAVOR "windows")
    elseif(APPLE)
        set(DEV_DEFAULT_FLAVOR "apple")
    elseif(EXISTS "/etc/debian_version")
        set(DEV_DEFAULT_FLAVOR "debian")
    elseif(EXISTS "/etc/redhat-release" OR EXISTS "/etc/fedora-release" OR EXISTS "/etc/SuSE-release")
        set(DEV_DEFAULT_FLAVOR "redhat")
    elseif(EXISTS "/etc/arch-release")
        set(DEV_DEFAULT_FLAVOR "arch")
    elseif(EXISTS "/etc/gentoo-release")
        set(DEV_DEFAULT_FLAVOR "gentoo")
    else()
        set(DEV_DEFAULT_FLAVOR "unknown")
    endif()
    if("${DEV_DEFAULT_FLAVOR}" STREQUAL "unknown")
        message("-- The default flavor identification failed, using failsafe method")
        if(WIN32)
            set(DEV_DEFAULT_FLAVOR "windows")
        elseif(APPLE)
            set(DEV_DEFAULT_FLAVOR "apple")
        else()
            set(DEV_DEFAULT_FLAVOR "debian")
        endif()
    endif()
    message("-- The default flavor is identified as \"${DEV_DEFAULT_FLAVOR}\"")
    set(DEV_DEFAULT_FLAVOR "${DEV_DEFAULT_FLAVOR}" CACHE STRING "Documentation and manual flavor")
endif()

if(DEFINED DEV_FLAVOR AND NOT "${DEV_FLAVOR}" MATCHES "^(windows|debian|gentoo)$")
    message(FATAL_ERROR "-- DEV_FLAVOR is invalid")
elseif(NOT DEFINED DEV_FLAVOR)
    set(DEV_FLAVOR "${DEV_DEFAULT_FLAVOR}")
endif()
function(devtemplate_set_default DEV_VARIABLE DEV_DEFAULT_VALUE)
    if(NOT DEFINED ${DEV_VARIABLE})
        set(${DEV_VARIABLE} "${DEV_DEFAULT_VALUE}" PARENT_SCOPE)
    endif()
endfunction()
if("${DEV_FLAVOR}" STREQUAL "windows")
    devtemplate_set_default(DEV_STRIP FALSE)
    devtemplate_set_default(DEV_DOCUMENTATION_NAME "${DEV_FILE_NAME}")
    #devtemplate_set_default(DEV_DOCUMENTATION_CHANGELOG_NAME "")
    #devtemplate_set_default(DEV_DOCUMENTATION_COPYRIGHT_NAME "")
    #devtemplate_set_default(DEV_DOCUMENTATION_README_NAME "")
    #devtemplate_set_default(DEV_MAN_NAME "")
elseif("${DEV_FLAVOR}" STREQUAL "debian")
    devtemplate_set_default(DEV_STRIP TRUE)
    devtemplate_set_default(DEV_DOCUMENTATION_NAME "${DEV_FILE_NAME}")
    devtemplate_set_default(DEV_DOCUMENTATION_CHANGELOG_NAME "changelog.gz")
    devtemplate_set_default(DEV_DOCUMENTATION_COPYRIGHT_NAME "copyright")
    #devtemplate_set_default(DEV_DOCUMENTATION_README_NAME "")
    devtemplate_set_default(DEV_MAN_NAME "${DEV_FILE_NAME}.${DEV_CATEGORY}.gz")
elseif("${DEV_FLAVOR}" STREQUAL "gentoo")
    devtemplate_set_default(DEV_STRIP FALSE)
    devtemplate_set_default(DEV_DOCUMENTATION_NAME "${DEV_FILE_NAME}-${DEV_VERSION}")
    #devtemplate_set_default(DEV_DOCUMENTATION_CHANGELOG_NAME "")
    #devtemplate_set_default(DEV_DOCUMENTATION_COPYRIGHT_NAME "")
    devtemplate_set_default(DEV_DOCUMENTATION_README_NAME "README.md")
    devtemplate_set_default(DEV_MAN_NAME "${DEV_FILE_NAME}.${DEV_CATEGORY}")
endif()

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

# CRT forcing (This section is sponsored by some smarty pants from Google who made GTest static by default)
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

# Custom add executable
function(devtemplate_add_executable TARGET_NAME)
    add_executable(${TARGET_NAME} ${ARGN})
    if (DEV_STRIP AND (CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "MinSizeRel"))
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND strip --strip-unneeded "$<TARGET_FILE:${TARGET_NAME}>")
    endif()
endfunction()

# Custom add library
function(devtemplate_add_library TARGET_NAME)
    add_library(${TARGET_NAME} ${ARGN})
    if (DEV_STRIP AND (CMAKE_BUILD_TYPE STREQUAL "Release" OR CMAKE_BUILD_TYPE STREQUAL "MinSizeRel"))
        add_custom_command(TARGET ${TARGET_NAME} POST_BUILD COMMAND strip --strip-unneeded "$<TARGET_FILE:${TARGET_NAME}>")
    endif()
endfunction()

# Transform paths from given property of given target into correct build+absolute/install+relative format
function(devtemplate_expand_property DEV_TARGET DEV_PROPERTY)
    get_target_property(DEV_PATHS ${DEV_TARGET} ${DEV_PROPERTY})
    foreach(DEV_PATH IN LISTS DEV_PATHS)
        file(RELATIVE_PATH DEV_RELATIVE_PATH "${PROJECT_SOURCE_DIR}" "${DEV_PATH}")
        list(APPEND DEV_RELATIVE_PATHS "$<BUILD_INTERFACE:${DEV_PATH}>$<INSTALL_INTERFACE:${DEV_RELATIVE_PATH}>")
    endforeach()
    set_target_properties(${DEV_TARGET} PROPERTIES ${DEV_PROPERTY} "${DEV_RELATIVE_PATHS}")
endfunction()

# Create target for copying file
function(devtemplate_copy_file DEV_TARGET_NAME DEV_ALL DEV_INPUT_PATH DEV_OUTPUT_PATH)
    get_filename_component(DEV_OUTPUT_NAME "${DEV_OUTPUT_PATH}" NAME)
    
    add_custom_command(OUTPUT "${DEV_OUTPUT_PATH}"
        COMMAND cmake -E copy "${DEV_INPUT_PATH}" "${DEV_OUTPUT_PATH}"
        DEPENDS "${DEV_INPUT_PATH}"
        COMMENT "Copying ${DEV_OUTPUT_NAME}"
        VERBATIM)
    if (DEV_ALL)
        set(DEV_ALL "ALL")
    else()
        set(DEV_ALL "")
    endif()
    add_custom_target(${DEV_TARGET_NAME} ${DEV_ALL} DEPENDS "${DEV_OUTPUT_PATH}")
endfunction()

# Create target for configuring file
function(devtemplate_configure_file DEV_TARGET_NAME DEV_ALL DEV_INPUT_PATH DEV_OUTPUT_PATH)
    get_filename_component(DEV_OUTPUT_NAME "${DEV_OUTPUT_PATH}" NAME)

    file(READ "${DEV_INPUT_PATH}" DEV_INPUT)
    if (EXISTS "${PROJECT_BINARY_DIR}/environment/${DEV_TARGET_NAME}.cmake")
        file(READ "${PROJECT_BINARY_DIR}/environment/${DEV_TARGET_NAME}.cmake" DEV_OLD_ENVIRONMENT)
    else()
        set(DEV_OLD_ENVIRONMENT)
    endif()
    get_cmake_property(DEV_VARIABLES VARIABLES)
    set(DEV_ENVIRONMENT)
    foreach (DEV_VARIABLE IN LISTS DEV_VARIABLES)
        if ("${DEV_INPUT}" MATCHES "^.*@${DEV_VARIABLE}@.*$") #"^.*(\\\${${DEV_VARIABLE}}|\\\$${DEV_VARIABLE}|@${DEV_VARIABLE}@).*$"
            set(DEV_ENVIRONMENT "${DEV_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
        endif()
    endforeach()
    if (NOT "${DEV_ENVIRONMENT}" STREQUAL "${DEV_OLD_ENVIRONMENT}")
        file(WRITE "${PROJECT_BINARY_DIR}/environment/${DEV_TARGET_NAME}.cmake" "${DEV_ENVIRONMENT}")
    elseif(NOT EXISTS "${PROJECT_BINARY_DIR}/environment/${DEV_TARGET_NAME}.cmake")
        file(WRITE "${PROJECT_BINARY_DIR}/environment/${DEV_TARGET_NAME}.cmake")
    endif()
    
    add_custom_command(OUTPUT "${DEV_OUTPUT_PATH}"
        COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/cmake/script/configure.cmake" "${DEV_INPUT_PATH}" "${PROJECT_BINARY_DIR}/environment/${DEV_TARGET_NAME}.cmake" "${DEV_OUTPUT_PATH}"
        DEPENDS "${DEV_INPUT_PATH}" "${PROJECT_BINARY_DIR}/environment/${DEV_TARGET_NAME}.cmake"
        COMMENT "Generating ${DEV_OUTPUT_NAME}"
        VERBATIM)
    if (DEV_ALL)
        set(DEV_ALL "ALL")
    else()
        set(DEV_ALL "")
    endif()
    add_custom_target(${DEV_TARGET_NAME} ${DEV_ALL} DEPENDS "${DEV_OUTPUT_PATH}")
endfunction()

# Configure and compress text file
function(devtemplate_configure_compress DEV_TARGET_NAME1 DEV_TARGET_NAME2 DEV_INPUT_PATH DEV_OUTPUT_PATH)
    get_filename_component(DEV_OUTPUT_NAME "${DEV_OUTPUT_PATH}" NAME)
    if("${DEV_OUTPUT_NAME}" MATCHES "\\.(bz2|gz)$")
        # Configuration
        string(REGEX REPLACE "\\.(bz2|gz)$" "" DEV_RAW_OUTPUT_PATH "${DEV_OUTPUT_PATH}")
        devtemplate_configure_file(${DEV_TARGET_NAME1} FALSE "${DEV_INPUT_PATH}" "${DEV_RAW_OUTPUT_PATH}")
        # Compression
        if("${DEV_OUTPUT_NAME}" MATCHES "\\.gz$")
            set(DEV_COMPRESS_COMMAND "gzip")
        else()
            set(DEV_COMPRESS_COMMAND "bzip2")
        endif()
        add_custom_command(OUTPUT "${DEV_OUTPUT_PATH}"
            COMMAND ${DEV_COMPRESS_COMMAND} -9 --stdout "${DEV_RAW_OUTPUT_PATH}" > "${DEV_OUTPUT_PATH}"
            DEPENDS "${DEV_RAW_OUTPUT_PATH}"
            COMMENT "Generating ${DEV_OUTPUT_NAME}"
            VERBATIM)
        add_custom_target(${DEV_TARGET_NAME2} DEPENDS "${DEV_OUTPUT_PATH}")
    else()
        # Configuration
        devtemplate_configure_file(${DEV_TARGET_NAME2} FALSE "${DEV_INPUT_PATH}" "${DEV_OUTPUT_PATH}")
    endif()
endfunction()

# Install icon
function(devtemplate_install_icon INPUT_FILE_NAME OUTPUT_DIR_NAME OUTPUT_FILE_NAME)
    install(FILES "${PROJECT_SOURCE_DIR}/icons/${INPUT_FILE_NAME}"
        RENAME "${OUTPUT_FILE_NAME}"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/${OUTPUT_DIR_NAME}/apps")
endfunction()

# Unset all DEV_* variables
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

# Configure environment
if(WIN32)
    devtemplate_configure_file(environment_bat FALSE "${PROJECT_SOURCE_DIR}/config/template/environment.bat" "${PROJECT_BINARY_DIR}/environment.bat")
endif()
if(UNIX)
    devtemplate_configure_file(environment_sh FALSE "${PROJECT_SOURCE_DIR}/config/template/environment.sh" "${PROJECT_BINARY_DIR}/environment.sh")
endif()
