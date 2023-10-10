# Defining manual generation
if (NOT WIN32)
    file(READ "${PROJECT_SOURCE_DIR}/config/template/manual" DEV_MAN)
    if (EXISTS "${PROJECT_BINARY_DIR}/manual-environment.cmake")
        file(READ "${PROJECT_BINARY_DIR}/manual-environment.cmake" DEV_OLD_MAN_ENVIRONMENT)
    endif()
    get_cmake_property(DEV_VARIABLES VARIABLES)
    set(DEV_MAN_ENVIRONMENT "")
    foreach (DEV_VARIABLE ${DEV_VARIABLES})
        if ("${DEV_MAN}" MATCHES ".*${DEV_VARIABLE}.*")
            set(DEV_MAN_ENVIRONMENT "${DEV_MAN_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
        endif()
    endforeach()
    if (NOT "${DEV_MAN_ENVIRONMENT}" STREQUAL "${DEV_OLD_MAN_ENVIRONMENT}")
        file(WRITE "${PROJECT_BINARY_DIR}/manual-environment.cmake" "${DEV_MAN_ENVIRONMENT}")
    endif()

    add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/manual"
    COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/script/configure.cmake" "${PROJECT_SOURCE_DIR}/config/template/manual" "${PROJECT_BINARY_DIR}/manual-environment.cmake" "${PROJECT_BINARY_DIR}/manual"
    DEPENDS "${PROJECT_SOURCE_DIR}/config/template/manual" "${PROJECT_BINARY_DIR}/manual-environment.cmake"
    COMMENT "Generating manual"
    VERBATIM)
    add_custom_target(man_raw DEPENDS "${PROJECT_BINARY_DIR}/manual")

    add_custom_command(OUTPUT "${PROJECT_BINARY_DIR}/manual.1"
    COMMAND gzip "${PROJECT_BINARY_DIR}/manual" --stdout > "${PROJECT_BINARY_DIR}/manual.1"
    DEPENDS "${PROJECT_BINARY_DIR}/manual"
    COMMENT "Generating manual.1"
    VERBATIM)
    add_custom_target(man ALL DEPENDS "${PROJECT_BINARY_DIR}/manual.1")
endif()