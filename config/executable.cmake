# Defining executable
add_executable(${PROJECT_NAME}_executable)
target_sources(${PROJECT_NAME}_executable PRIVATE "executable/executable.cpp")
target_link_libraries(${PROJECT_NAME}_executable PUBLIC ${PROJECT_NAME})
add_custom_target(run COMMAND ${PROJECT_NAME}_executable)