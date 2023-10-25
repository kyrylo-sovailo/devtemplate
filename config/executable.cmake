##################################
# Define command-line executable #
##################################

# Define executable
add_executable(${DEV_CMAKE_NAME}_executable)
target_link_libraries(${DEV_CMAKE_NAME}_executable PUBLIC ${DEV_CMAKE_NAME})

# Define executable sources
target_sources(${DEV_CMAKE_NAME}_executable PRIVATE "executable/executable.cpp")

# Define properties
set_target_properties(${DEV_CMAKE_NAME}_executable PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}_executable")

# Define "run" command
add_custom_target(run COMMAND ${DEV_CMAKE_NAME}_executable)