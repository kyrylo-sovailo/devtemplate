# Defining documentation generation
find_package(Doxygen REQUIRED)
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/documentation")
get_target_property(DEV_INTERFACE_SOURCES ${DEV_CMAKE_NAME} INTERFACE_SOURCES)

file(READ "${PROJECT_SOURCE_DIR}/config/template/Doxyfile" DEV_DOXYFILE)
file(READ "${PROJECT_SOURCE_DIR}/config/template/documentation.h" DEV_DOCUMENTATION)
if (EXISTS "${PROJECT_BINARY_DIR}/doxyfile-environment.cmake")
    file(READ "${PROJECT_BINARY_DIR}/doxyfile-environment.cmake" DEV_OLD_DOXYFILE_ENVIRONMENT)
endif()
if (EXISTS "${PROJECT_BINARY_DIR}/documentation-environment.cmake")
    file(READ "${PROJECT_BINARY_DIR}/documentation-environment.cmake" DEV_OLD_DOCUMENTATION_ENVIRONMENT)
endif()
get_cmake_property(DEV_VARIABLES VARIABLES)
set(DEV_DOXYFILE_ENVIRONMENT "")
set(DEV_DOCUMENTATION_ENVIRONMENT "")
foreach (DEV_VARIABLE ${DEV_VARIABLES})
    if ("${DEV_DOXYFILE}" MATCHES ".*${DEV_VARIABLE}.*")
        set(DEV_DOXYFILE_ENVIRONMENT "${DEV_DOXYFILE_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
    endif()
    if ("${DEV_DOCUMENTATION}" MATCHES ".*${DEV_VARIABLE}.*")
        set(DEV_DOCUMENTATION_ENVIRONMENT "${DEV_DOCUMENTATION_ENVIRONMENT}set(${DEV_VARIABLE} \"${${DEV_VARIABLE}}\")\n")
    endif()
endforeach()
if (NOT "${DEV_DOXYFILE_ENVIRONMENT}" STREQUAL "${DEV_OLD_DOXYFILE_ENVIRONMENT}")
    file(WRITE "${PROJECT_BINARY_DIR}/doxyfile-environment.cmake" "${DEV_DOXYFILE_ENVIRONMENT}")
endif()
if (NOT "${DEV_DOCUMENTATION_ENVIRONMENT}" STREQUAL "${DEV_OLD_DOCUMENTATION_ENVIRONMENT}")
    file(WRITE "${PROJECT_BINARY_DIR}/documentation-environment.cmake" "${DEV_DOCUMENTATION_ENVIRONMENT}")
endif()

add_custom_command(OUTPUT "${CMAKE_BINARY_DIR}/Doxyfile"
COMMAND cmake -P "${CMAKE_SOURCE_DIR}/config/script/doxyfile.cmake" "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}"
DEPENDS "${CMAKE_SOURCE_DIR}/config/template/Doxyfile" "${PROJECT_BINARY_DIR}/doxyfile-environment.cmake"
COMMENT "Generating Doxyfile"
VERBATIM)
add_custom_target(doxyfile ALL DEPENDS "${CMAKE_BINARY_DIR}/Doxyfile")

add_custom_command(OUTPUT "${CMAKE_BINARY_DIR}/documentation.h"
COMMAND cmake -P "${CMAKE_SOURCE_DIR}/config/script/documentation.cmake" "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}"
DEPENDS "${CMAKE_SOURCE_DIR}/config/template/documentation.h" "${PROJECT_BINARY_DIR}/documentation-environment.cmake"
COMMENT "Generating documentation.h"
VERBATIM)
add_custom_target(documentation ALL DEPENDS "${CMAKE_BINARY_DIR}/documentation.h")

add_custom_command(OUTPUT "${CMAKE_BINARY_DIR}/documentation.stamp"
COMMAND doxygen "${CMAKE_BINARY_DIR}/Doxyfile"
COMMAND cmake -E touch "${CMAKE_BINARY_DIR}/documentation.stamp"
DEPENDS "${CMAKE_BINARY_DIR}/Doxyfile" "${CMAKE_BINARY_DIR}/documentation.h" "${DEV_INTERFACE_SOURCES}"
COMMENT "Generating documentation"
VERBATIM)
add_custom_target(doc ALL DEPENDS "${CMAKE_BINARY_DIR}/documentation.stamp")