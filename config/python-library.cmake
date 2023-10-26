#########################
# Define Python wrapper #
#########################

# Dependencies
find_package(Python COMPONENTS Interpreter Development REQUIRED)
find_package(pybind11 CONFIG REQUIRED)

# Define library
add_library(${DEV_CMAKE_NAME}_python SHARED)
list(APPEND DEV_PACKAGE_TARGETS ${DEV_CMAKE_NAME}_python)
target_link_libraries(${DEV_CMAKE_NAME}_python PRIVATE ${DEV_CMAKE_NAME})
# cmake >= 3.15: link_libraries(pybind11::module)
execute_process(COMMAND python3-config --includes OUTPUT_VARIABLE DEV_PYTHON_INCLUDES)
execute_process(COMMAND python3-config --libs OUTPUT_VARIABLE DEV_PYTHON_LIBS)
string(REPLACE "-I" "" DEV_PYTHON_INCLUDES "${DEV_PYTHON_INCLUDES}")
string(REGEX REPLACE "[\r\n]" "" DEV_PYTHON_INCLUDES "${DEV_PYTHON_INCLUDES}")
string(REGEX REPLACE "[ ]+" ";" DEV_PYTHON_INCLUDES "${DEV_PYTHON_INCLUDES}")
string(REGEX REPLACE "[\r\n]" "" DEV_PYTHON_LIBS "${DEV_PYTHON_LIBS}")
string(REGEX REPLACE "[ ]+" ";" DEV_PYTHON_LIBS "${DEV_PYTHON_LIBS}")
target_include_directories(${DEV_CMAKE_NAME}_python PRIVATE "${DEV_PYTHON_INCLUDES}")
target_link_libraries(${DEV_CMAKE_NAME}_python PRIVATE "${DEV_PYTHON_LIBS}")

# Define executable sources
target_sources(${DEV_CMAKE_NAME}_python PRIVATE "python/python.cpp")

# Define properties
set_target_properties(${DEV_CMAKE_NAME}_python PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}")
set_target_properties(${DEV_CMAKE_NAME}_python PROPERTIES PREFIX "")