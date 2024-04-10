####################################
# Define command for Python script #
####################################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME}_python)
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}_python\" does not exist, cannot create command for Python script")
endif()

# Define python execute command ("run_python" target)
add_custom_target(run_python COMMAND "${Python_EXECUTABLE}" "${PROJECT_SOURCE_DIR}/python/executable.py" DEPENDS ${DEV_CMAKE_NAME}_python)