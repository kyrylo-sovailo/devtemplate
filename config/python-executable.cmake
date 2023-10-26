####################################
# Define command for Python script #
####################################

add_custom_target(run_python COMMAND python3 "${PROJECT_SOURCE_DIR}/python/executable.py" DEPENDS ${DEV_CMAKE_NAME}_python)