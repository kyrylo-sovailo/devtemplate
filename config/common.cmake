####################
# Common functions #
####################

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

# Common functions
function(devtemplate_expand_property DEV_TARGET DEV_PROPERTY)
    get_target_property(DEV_PATHS ${DEV_TARGET} ${DEV_PROPERTY})
    foreach(DEV_PATH IN LISTS DEV_PATHS)
        file(RELATIVE_PATH DEV_RELATIVE_PATH "${PROJECT_SOURCE_DIR}" "${DEV_PATH}")
        list(APPEND DEV_RELATIVE_PATHS "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/${DEV_RELATIVE_PATH}>$<INSTALL_INTERFACE:${DEV_RELATIVE_PATH}>")
    endforeach()
    set_target_properties(${DEV_TARGET} PROPERTIES ${DEV_PROPERTY} "${DEV_RELATIVE_PATHS}")
endfunction()

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
        DEPENDS "${DEV_INPUT_PATH}"
        COMMENT "Generating ${DEV_OUTPUT_NAME}"
        VERBATIM)
    if (DEV_ALL)
        set(DEV_ALL "ALL")
    else()
        set(DEV_ALL "")
    endif()
    add_custom_target(${DEV_TARGET_NAME} ${DEV_ALL} DEPENDS "${DEV_OUTPUT_PATH}")
endfunction()

function(devtemplate_install_icon INPUT_FILE_NAME OUTPUT_DIR_NAME OUTPUT_FILE_NAME)
    install(FILES "${PROJECT_SOURCE_DIR}/icons/${INPUT_FILE_NAME}"
        RENAME "${OUTPUT_FILE_NAME}"
        DESTINATION "${CMAKE_INSTALL_DATADIR}/icons/hicolor/${OUTPUT_DIR_NAME}/apps")
endfunction()

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
