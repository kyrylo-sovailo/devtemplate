#####################
# Define test suite #
#####################

# Dependencies
find_package(GTest REQUIRED)

# Define test
add_executable(${DEV_CMAKE_NAME}_test)
list(APPEND DEV_EXPORT_TARGETS ${DEV_CMAKE_NAME}_test)
list(APPEND DEV_PACKAGE_TARGETS ${DEV_CMAKE_NAME}_test)
target_link_libraries(${DEV_CMAKE_NAME}_test PRIVATE ${DEV_CMAKE_NAME})
target_link_libraries(${DEV_CMAKE_NAME}_test PRIVATE GTest::GTest)

# Define test sources
target_sources(${DEV_CMAKE_NAME}_test PRIVATE "executable/test.cpp")

# Define properties
set_target_properties(${DEV_CMAKE_NAME}_test PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}_test")

# Define "test" command
add_custom_target(test COMMAND ${DEV_CMAKE_NAME}_test)