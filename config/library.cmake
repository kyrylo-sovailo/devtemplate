# Defining header files and library target
add_library(${PROJECT_NAME} SHARED)
target_sources(${PROJECT_NAME} INTERFACE "include/devtemplate/devtemplate.h")
target_sources(${PROJECT_NAME} PRIVATE "source/source.cpp")
target_include_directories(${PROJECT_NAME} INTERFACE "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>" "$<INSTALL_INTERFACE:include>")