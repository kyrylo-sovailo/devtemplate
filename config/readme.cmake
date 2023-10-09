# README.md generation
file(READ "${PROJECT_SOURCE_DIR}/config/template/README.md" DEV_README)
if (EXISTS "${PROJECT_BINARY_DIR}/readme-environment.cmake")
    file(READ "${PROJECT_BINARY_DIR}/readme-environment.cmake" DEV_OLD_ENVIRONMENT)
endif()

get_cmake_property(DEV_VARIABLES VARIABLES)
set(DEV_ENVIRONMENT "")
foreach (DEV_VARIABLE ${DEV_VARIABLES})
    if ("${DEV_README}" MATCHES ".*${DEV_VARIABLE}.*")
        set(DEV_ENVIRONMENT "${DEV_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
    endif()
endforeach()

if (NOT "${DEV_ENVIRONMENT}" STREQUAL "${DEV_OLD_ENVIRONMENT}")
    file(WRITE "${PROJECT_BINARY_DIR}/readme-environment.cmake" "${DEV_ENVIRONMENT}")
endif()

add_custom_command(OUTPUT "${CMAKE_SOURCE_DIR}/README.md"
COMMAND cmake -P "${CMAKE_SOURCE_DIR}/config/script/readme.cmake" "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}"
DEPENDS "${CMAKE_SOURCE_DIR}/config/template/README.md" "${PROJECT_BINARY_DIR}/readme-environment.cmake"
COMMENT "Generating README.md"
VERBATIM)
add_custom_target(readme ALL DEPENDS "${CMAKE_SOURCE_DIR}/README.md")

#list (SORT DEV_VARIABLES)
#file(WRITE "${PROJECT_BINARY_DIR}/variables.txt" "")
#foreach (DEV_VARIABLE ${DEV_VARIABLES})
#    file(APPEND "${PROJECT_BINARY_DIR}/variables.txt" "${DEV_VARIABLE}=${${DEV_VARIABLE}}\n")
#endforeach()