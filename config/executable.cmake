# Defining executable
add_executable(${PROJECT_NAME}_executable "executable/executable.cpp")
target_link_libraries(${PROJECT_NAME}_executable ${${PROJECT_NAME}_PRIVATE_TYPE} ${PROJECT_NAME})