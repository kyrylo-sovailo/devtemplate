# Defining header files and header-only target
set(${PROJECT_NAME}_TYPE INTERFACE)
set(${PROJECT_NAME}_PUBLIC_TYPE INTERFACE)
set(${PROJECT_NAME}_PRIVATE_TYPE INTERFACE)
set(${PROJECT_NAME}_HEADERS include/devtemplate/devtemplate.h)
add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME} INTERFACE "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>" "$<INSTALL_INTERFACE:include>")