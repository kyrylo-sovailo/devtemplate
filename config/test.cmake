#####################
# Define test suite #
#####################

# Dependecies
if (NOT TARGET ${DEV_CMAKE_NAME})
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}\" does not exist, cannot create test")
endif()

# Define test
add_executable(${DEV_CMAKE_NAME}_test)
list(APPEND DEV_EXPORT_TARGETS ${DEV_CMAKE_NAME}_test)
list(APPEND DEV_PACKAGE_TARGETS ${DEV_CMAKE_NAME}_test)
set_target_properties(${DEV_CMAKE_NAME}_executable_gui PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}_test")

# Link dependencies
target_link_libraries(${DEV_CMAKE_NAME}_test PRIVATE ${DEV_CMAKE_NAME})
find_package(GTest REQUIRED)
target_link_libraries(${DEV_CMAKE_NAME}_test PRIVATE GTest::GTest)

# Define sources
target_sources(${DEV_CMAKE_NAME}_test PRIVATE "executable/test.cpp")

# Define "test" command
add_custom_target(test COMMAND ${DEV_CMAKE_NAME}_test)
