# Defining test suite
find_package(GTest REQUIRED)
add_executable(${PROJECT_NAME}_test)
target_sources(${PROJECT_NAME}_test PRIVATE "executable/test.cpp")
target_link_libraries(${PROJECT_NAME}_test PUBLIC ${PROJECT_NAME})
target_link_libraries(${PROJECT_NAME}_test PUBLIC GTest::gtest)
add_custom_target(test COMMAND ${PROJECT_NAME}_test)