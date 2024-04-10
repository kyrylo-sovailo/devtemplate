##################################
# Define command for Python test #
##################################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME}_python)
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}_python\" does not exist, cannot create command for Python test script")
endif()

# Define python test suite ("test_python" target)
add_custom_target(test_python COMMAND "${Python_EXECUTABLE}" "${PROJECT_SOURCE_DIR}/python/test.py" DEPENDS ${DEV_CMAKE_NAME}_python)