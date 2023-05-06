# Header
cmake_minimum_required(VERSION 3.15)
project(devtemplate VERSION 0.0.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

# Library
add_library(${CMAKE_PROJECT_NAME} SHARED source/source.cpp)
target_include_directories(${CMAKE_PROJECT_NAME} PUBLIC "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>" "$<INSTALL_INTERFACE:include>")
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES PREFIX "lib")

# Bindings
find_package(pybind11)
find_package(Python)
if (pybind11_FOUND AND Python_FOUND)
    add_library(${CMAKE_PROJECT_NAME}_python MODULE python/python.cpp)
    target_link_libraries(${CMAKE_PROJECT_NAME}_python PUBLIC ${CMAKE_PROJECT_NAME})
    target_link_libraries(${CMAKE_PROJECT_NAME}_python PUBLIC pybind11::module)
    set_target_properties(${CMAKE_PROJECT_NAME}_python PROPERTIES OUTPUT_NAME ${CMAKE_PROJECT_NAME} PREFIX "")
endif()

# Example
add_executable(${CMAKE_PROJECT_NAME}_example example/example.cpp)
target_link_libraries(${CMAKE_PROJECT_NAME}_example PUBLIC ${CMAKE_PROJECT_NAME})

# Installation
include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

configure_package_config_file("${CMAKE_SOURCE_DIR}/config/config.cmake.in"
    "${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}")

write_basic_package_version_file("${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${CMAKE_PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion)

install(TARGETS ${CMAKE_PROJECT_NAME}
    EXPORT ${CMAKE_PROJECT_NAME}_targets
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

install(EXPORT ${CMAKE_PROJECT_NAME}_targets
    FILE "${CMAKE_PROJECT_NAME}Targets.cmake"
    NAMESPACE ${CMAKE_PROJECT_NAME}::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}")

install(FILES "include/${CMAKE_PROJECT_NAME}/${CMAKE_PROJECT_NAME}.h"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${CMAKE_PROJECT_NAME}")

install(FILES "${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}Config.cmake" "${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${CMAKE_PROJECT_NAME}")

if (pybind11_FOUND AND Python_FOUND)
    execute_process(COMMAND python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR} "${CMAKE_SOURCE_DIR}/config/path.py" "${CMAKE_INSTALL_LIBDIR}" OUTPUT_VARIABLE PYTHONPATH RESULT_VARIABLE PYTHONRES)
    string(REGEX REPLACE "[\n\r]" "" PYTHONPATH "${PYTHONPATH}")
    if (${PYTHONRES} EQUAL 0)
        install(TARGETS ${CMAKE_PROJECT_NAME}_python
            LIBRARY DESTINATION "${PYTHONPATH}")
    else()
        message(WARNING "Could not find Python site-packages directory, omitting installation of Python bindings")
    endif()
endif()

# Export
export(EXPORT ${CMAKE_PROJECT_NAME}_targets
    FILE "${CMAKE_PROJECT_NAME}Targets.cmake"
    NAMESPACE ${CMAKE_PROJECT_NAME}::)

# Uninstallation
add_custom_target(uninstall WORKING_DIRECTORY "${CMAKE_BUILD_DIR}" COMMAND cmake -P "${CMAKE_SOURCE_DIR}/config/uninstall.cmake" ${CMAKE_PROJECT_NAME})

# Documentation
find_package(Doxygen)
if (Doxygen_FOUND)
    file(MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/documentation")
    add_custom_target(doc WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}" COMMAND doxygen "${CMAKE_SOURCE_DIR}/config/Doxyfile")
endif()