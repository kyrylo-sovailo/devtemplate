# Defining header files and library target
add_library(${DEV_CMAKE_NAME} ${DEV_TYPE})
if ("${DEV_TYPE}" STREQUAL "INTERFACE")
    target_sources(${DEV_CMAKE_NAME} INTERFACE "include/devtemplate/devtemplate.hpp")
else()
    target_sources(${DEV_CMAKE_NAME} INTERFACE "include/devtemplate/devtemplate.h")
    target_sources(${DEV_CMAKE_NAME} PRIVATE "source/source.cpp")
endif()
target_include_directories(${DEV_CMAKE_NAME} INTERFACE "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>" "$<INSTALL_INTERFACE:include>")
target_compile_definitions(${DEV_CMAKE_NAME} INTERFACE
    ${DEV_MACRO_NAME}_NAME="${DEV_NAME}"
    ${DEV_MACRO_NAME}_CMAKE_NAME="${DEV_CMAKE_NAME}"
    ${DEV_MACRO_NAME}_FILE_NAME="${DEV_FILE_NAME}"
    ${DEV_MACRO_NAME}_MACRO_NAME="${DEV_MACRO_NAME}"
    ${DEV_MACRO_NAME}_MAJOR="${DEV_MAJOR}"
    ${DEV_MACRO_NAME}_MINOR="${DEV_MINOR}"
    ${DEV_MACRO_NAME}_PATCH="${DEV_PATCH}"
    ${DEV_MACRO_NAME}_TYPE="${DEV_TYPE}"
    ${DEV_MACRO_NAME}_${DEV_TYPE}
    ${DEV_MACRO_NAME}_DESCRIPTION="${DEV_DESCRIPTION}"
    ${DEV_MACRO_NAME}_HOMEPAGE="${DEV_HOMEPAGE}"
    ${DEV_MACRO_NAME}_EMAIL="${DEV_EMAIL}"
    ${DEV_MACRO_NAME}_AUTHOR="${DEV_AUTHOR}")
if (WIN32)
    target_compile_definitions(${DEV_CMAKE_NAME} INTERFACE ${DEV_MACRO_NAME}_EXPORT="__declspec\(dllexport\)")
    target_compile_definitions(${DEV_CMAKE_NAME} PRIVATE ${DEV_MACRO_NAME}_EXPORT="__declspec\(dllimport\)")
else()
    target_compile_definitions(${DEV_CMAKE_NAME} INTERFACE ${DEV_MACRO_NAME})
endif()