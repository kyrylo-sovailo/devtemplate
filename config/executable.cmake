##################################
# Define command-line executable #
##################################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME})
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}\" does not exist, cannot create executable")
endif()

# Define executable
add_executable(${DEV_CMAKE_NAME}_executable)
list(APPEND DEV_EXPORT_TARGETS ${DEV_CMAKE_NAME}_executable)
list(APPEND DEV_PACKAGE_TARGETS ${DEV_CMAKE_NAME}_executable)
set_target_properties(${DEV_CMAKE_NAME}_executable PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}-executable$<$<CONFIG:Debug>:-debug>")

# Link dependencies
target_link_libraries(${DEV_CMAKE_NAME}_executable PRIVATE ${DEV_CMAKE_NAME})

# Define sources
target_sources(${DEV_CMAKE_NAME}_executable PRIVATE "executable/executable.cpp")

# Define executable ("run" target)
add_custom_target(run COMMAND ${DEV_CMAKE_NAME}_executable)
