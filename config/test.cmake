# Defining test suite
find_package(GTest REQUIRED)
add_executable(${DEV_CMAKE_NAME}_test)
target_sources(${DEV_CMAKE_NAME}_test PRIVATE "executable/test.cpp")
target_link_libraries(${DEV_CMAKE_NAME}_test PUBLIC ${DEV_CMAKE_NAME})
target_link_libraries(${DEV_CMAKE_NAME}_test PUBLIC GTest::gtest)
add_custom_target(test COMMAND ${DEV_CMAKE_NAME}_test)