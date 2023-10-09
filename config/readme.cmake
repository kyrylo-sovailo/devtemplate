# README.md generation
file(READ "${PROJECT_SOURCE_DIR}/config/template/README.md" DEV_README)
if (EXISTS "${PROJECT_BINARY_DIR}/readme-environment.cmake")
    file(READ "${PROJECT_BINARY_DIR}/readme-environment.cmake" DEV_OLD_README_ENVIRONMENT)
endif()
get_cmake_property(DEV_VARIABLES VARIABLES)
set(DEV_README_ENVIRONMENT "")
foreach (DEV_VARIABLE ${DEV_VARIABLES})
    if ("${DEV_README}" MATCHES ".*${DEV_VARIABLE}.*")
        set(DEV_README_ENVIRONMENT "${DEV_README_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
    endif()
endforeach()
if (NOT "${DEV_README_ENVIRONMENT}" STREQUAL "${DEV_OLD_README_ENVIRONMENT}")
    file(WRITE "${PROJECT_BINARY_DIR}/readme-environment.cmake" "${DEV_README_ENVIRONMENT}")
endif()

add_custom_command(OUTPUT "${PROJECT_SOURCE_DIR}/README.md"
COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/script/readme.cmake" "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}"
DEPENDS "${PROJECT_SOURCE_DIR}/config/template/README.md" "${PROJECT_BINARY_DIR}/readme-environment.cmake"
COMMENT "Generating README.md"
VERBATIM)
add_custom_target(readme ALL DEPENDS "${PROJECT_SOURCE_DIR}/README.md")