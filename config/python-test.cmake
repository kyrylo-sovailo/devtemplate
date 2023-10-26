##################################
# Define command for Python test #
##################################

add_custom_target(test_python COMMAND python3 "${PROJECT_SOURCE_DIR}/python/test.py" DEPENDS ${DEV_CMAKE_NAME}_python)