####################
# Common functions #
####################

include(GNUInstallDirs)

function(devtemplate_cleanup)
    get_cmake_property(DEV_VARIABLES VARIABLES)
    foreach (DEV_VARIABLE ${DEV_VARIABLES})
        if ("${DEV_VARIABLE}" MATCHES "^DEV_.+&" AND (NOT "${DEV_VARIABLE}" STREQUAL "DEV_VARIABLE") AND (NOT "${DEV_VARIABLE}" STREQUAL "DEV_VARIABLES"))
            unset(${DEV_VARIABLE} PARENT_SCOPE)
        endif()
    endforeach()
    unset(DEV_VARIABLE PARENT_SCOPE)
    unset(DEV_VARIABLS PARENT_SCOPE)
endfunction()

function(devtemplate_configure_file DEV_TARGET_NAME DEV_ALL DEV_INPUT_PATH DEV_OUTPUT_PATH)
    get_filename_component(DEV_OUTPUT_NAME "${DEV_OUTPUT_PATH}" NAME)

    file(READ "${DEV_INPUT_PATH}" DEV_INPUT)
    if (EXISTS "${PROJECT_BINARY_DIR}/${DEV_OUTPUT_NAME}.cmake")
        file(READ "${PROJECT_BINARY_DIR}/${DEV_OUTPUT_NAME}.cmake" DEV_OLD_ENVIRONMENT)
    else()
        set(DEV_OLD_ENVIRONMENT)
    endif()
    get_cmake_property(DEV_VARIABLES VARIABLES)
    set(DEV_ENVIRONMENT)
    foreach (DEV_VARIABLE ${DEV_VARIABLES})
        if ("${DEV_INPUT}" MATCHES "^.*(\\\${${DEV_VARIABLE}}|\\\$${DEV_VARIABLE}|@${DEV_VARIABLE}@).*$")
            set(DEV_ENVIRONMENT "${DEV_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
        endif()
    endforeach()
    if (NOT "${DEV_ENVIRONMENT}" STREQUAL "${DEV_OLD_ENVIRONMENT}")
        file(WRITE "${PROJECT_BINARY_DIR}/${DEV_OUTPUT_NAME}.cmake" "${DEV_ENVIRONMENT}")
    elseif(NOT EXISTS "${PROJECT_BINARY_DIR}/${DEV_OUTPUT_NAME}.cmake")
        file(WRITE "${PROJECT_BINARY_DIR}/${DEV_OUTPUT_NAME}.cmake")
    endif()
    
    add_custom_command(OUTPUT "${DEV_OUTPUT_PATH}"
        COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/script/configure.cmake" "${DEV_INPUT_PATH}" "${PROJECT_BINARY_DIR}/${DEV_OUTPUT_NAME}.cmake" "${DEV_OUTPUT_PATH}"
        DEPENDS "${DEV_INPUT_PATH}"
        COMMENT "Generating ${DEV_OUTPUT_NAME}"
        VERBATIM)
    if (${DEV_ALL})
        set(DEV_ALL ALL)
    else()
        set(DEV_ALL)
    endif()
    add_custom_target(${DEV_TARGET_NAME} ${DEV_ALL} DEPENDS "${DEV_OUTPUT_PATH}")
endfunction()