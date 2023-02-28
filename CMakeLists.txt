cmake_minimum_required(VERSION 3.0)
project(devtemplate LANGUAGES CXX)

add_executable(devtemplate source/devtemplate.cpp)

find_package(Doxygen)
if (Doxygen_FOUND)
    add_custom_target(doc WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}" COMMAND sh -c 'if [ ! -d documentation ]\; then mkdir documentation\; fi\; doxygen')
endif()