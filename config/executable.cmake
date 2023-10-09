# Defining executable
add_executable(${DEV_CMAKE_NAME}_executable)
target_sources(${DEV_CMAKE_NAME}_executable PRIVATE "executable/executable.cpp")
target_link_libraries(${DEV_CMAKE_NAME}_executable PUBLIC ${DEV_CMAKE_NAME})
add_custom_target(run COMMAND ${DEV_CMAKE_NAME}_executable)