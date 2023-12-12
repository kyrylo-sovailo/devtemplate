#########################
# Define Python wrapper #
#########################

# Dependecies
if (NOT TARGET ${DEV_CMAKE_NAME})
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}\" does not exist, cannot create Python wrapper")
endif()

# Define library
add_library(${DEV_CMAKE_NAME}_python SHARED)
list(APPEND DEV_PACKAGE_TARGETS ${DEV_CMAKE_NAME}_python)

# Link dependencies
target_link_libraries(${DEV_CMAKE_NAME}_python PRIVATE ${DEV_CMAKE_NAME})
find_package(Python COMPONENTS Interpreter Development REQUIRED)
if (NOT WIN32)
    find_package(pybind11 CONFIG REQUIRED)
else()
    find_package(pybind11 CONFIG REQUIRED HINTS "${Python_SITELIB}/pybind11/share/cmake/pybind11")
endif()
target_link_libraries(${DEV_CMAKE_NAME}_python PRIVATE pybind11::module)

# Define executable sources
target_sources(${DEV_CMAKE_NAME}_python PRIVATE "python/python.cpp")

# Define properties
set_target_properties(${DEV_CMAKE_NAME}_python PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}")
set_target_properties(${DEV_CMAKE_NAME}_python PROPERTIES PREFIX "")
