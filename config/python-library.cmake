#############################
# Define the Python wrapper #
#############################

# Dependencies
find_package(pybind11 CONFIG REQUIRED)

# Define library
add_library(${DEV_CMAKE_NAME}_python SHARED)
target_link_libraries(${DEV_CMAKE_NAME}_python PUBLIC ${DEV_CMAKE_NAME})
target_link_libraries(${DEV_CMAKE_NAME}_python PUBLIC pybind11::module)

# Define executable sources
target_sources(${DEV_CMAKE_NAME}_python PRIVATE "python/python.cpp")

# Define properties
set_target_properties(${DEV_CMAKE_NAME}_python PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}")
set_target_properties(${DEV_CMAKE_NAME}_python PROPERTIES PREFIX "")