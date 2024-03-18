#####################
# Define test suite #
#####################

# Dependecies
if (NOT TARGET ${DEV_CMAKE_NAME})
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}\" does not exist, cannot create test")
endif()

# Add global flags on Windows for compatibility with GTest (see README)
if (WIN32 AND dev_force_static_crt)
    add_compile_definitions(_ITERATOR_DEBUG_LEVEL=0)
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
        add_compile_options(/MT)
    elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" AND "${CMAKE_CXX_SIMULATE_ID}" STREQUAL "MSVC")
        if ("${CMAKE_CXX_COMPILER_FRONTEND_VARIANT}" STREQUAL "MSVC")
            add_compile_options(/MT)
        else()
            string(REGEX REPLACE "-D_DLL|-D_DEBUG" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")
            string(REGEX REPLACE "-D_DLL|-D_DEBUG" "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
        endif()
    endif()
endif()

# Define test
add_executable(${DEV_CMAKE_NAME}_test)
list(APPEND DEV_EXPORT_TARGETS ${DEV_CMAKE_NAME}_test)
list(APPEND DEV_PACKAGE_TARGETS ${DEV_CMAKE_NAME}_test)
set_target_properties(${DEV_CMAKE_NAME}_test PROPERTIES OUTPUT_NAME "${DEV_FILE_NAME}-test$<$<CONFIG:Debug>:-debug>")

# Link dependencies
target_link_libraries(${DEV_CMAKE_NAME}_test PRIVATE ${DEV_CMAKE_NAME})
if (NOT WIN32)
    find_package(GTest REQUIRED)
    target_link_libraries(${DEV_CMAKE_NAME}_test PRIVATE GTest::GTest)
elseif (CMAKE_SIZEOF_VOID_P EQUAL 8)
    find_package(GTest REQUIRED HINTS "$ENV{PROGRAMFILES}/googletest-distribution/lib/cmake/GTest")
    target_link_libraries(${DEV_CMAKE_NAME}_test PRIVATE GTest::gtest)
elseif (CMAKE_SIZEOF_VOID_P EQUAL 4)
    find_package(GTest REQUIRED HINTS "$ENV{PROGRAMFILES\(X86\)}/googletest-distribution/lib/cmake/GTest")
    target_link_libraries(${DEV_CMAKE_NAME}_test PRIVATE GTest::gtest)
endif()

# Define sources
target_sources(${DEV_CMAKE_NAME}_test PRIVATE "executable/test.cpp")

# Define "test" command
add_custom_target(test COMMAND ${DEV_CMAKE_NAME}_test)
