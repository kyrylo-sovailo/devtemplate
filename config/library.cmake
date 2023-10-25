#######################
# Define core library #
#######################

# Define library
add_library(${DEV_CMAKE_NAME} ${DEV_TYPE})

# Define headers and sources
if ("${DEV_TYPE}" STREQUAL "INTERFACE")
    target_sources(${DEV_CMAKE_NAME} INTERFACE "include/devtemplate/devtemplate.hpp")
else()
    target_sources(${DEV_CMAKE_NAME} INTERFACE "include/devtemplate/devtemplate.h")
    target_sources(${DEV_CMAKE_NAME} PRIVATE "source/source.cpp")
endif()
devtemplate_expand_property(${DEV_CMAKE_NAME} INTERFACE_SOURCES)

# Define properties
set_target_properties(${DEV_CMAKE_NAME} PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}")
target_include_directories(${DEV_CMAKE_NAME} INTERFACE "include")
devtemplate_expand_property(${DEV_CMAKE_NAME} INTERFACE_INCLUDE_DIRECTORIES)

# Define macros
target_compile_definitions(${DEV_CMAKE_NAME} INTERFACE
    ${DEV_MACRO_NAME}_NAME=${DEV_NAME}
    ${DEV_MACRO_NAME}_CMAKE_NAME=${DEV_CMAKE_NAME}
    ${DEV_MACRO_NAME}_FILE_NAME=${DEV_FILE_NAME}
    ${DEV_MACRO_NAME}_MACRO_NAME=${DEV_MACRO_NAME}
    ${DEV_MACRO_NAME}_MAJOR=${DEV_MAJOR}
    ${DEV_MACRO_NAME}_MINOR=${DEV_MINOR}
    ${DEV_MACRO_NAME}_PATCH=${DEV_PATCH}
    ${DEV_MACRO_NAME}_TYPE=${DEV_TYPE}
    ${DEV_MACRO_NAME}_${DEV_TYPE}
    ${DEV_MACRO_NAME}_DESCRIPTION=${DEV_DESCRIPTION}
    ${DEV_MACRO_NAME}_HOMEPAGE=${DEV_HOMEPAGE}
    ${DEV_MACRO_NAME}_EMAIL=${DEV_EMAIL}
    ${DEV_MACRO_NAME}_AUTHOR=${DEV_AUTHOR})

if (WIN32 AND "${DEV_TYPE}" STREQUAL "SHARED")
    target_compile_definitions(${DEV_CMAKE_NAME} INTERFACE ${DEV_MACRO_NAME}_EXPORT="__declspec\(dllexport\)")
    target_compile_definitions(${DEV_CMAKE_NAME} PRIVATE ${DEV_MACRO_NAME}_EXPORT="__declspec\(dllimport\)")
else()
    target_compile_definitions(${DEV_CMAKE_NAME} INTERFACE ${DEV_MACRO_NAME})
endif()