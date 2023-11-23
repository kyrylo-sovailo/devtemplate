##########################
# Install Python wrapper #
##########################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME}_python)
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}_python\" does not exist, cannot install Python wrapper")
endif()

# Install Python wrapper
if ("${Python_SITELIB}" MATCHES "^/usr/")
    string(REGEX REPLACE "^/usr/" "" DEV_PYTHON_PATH "${Python_SITELIB}")
else()
    set(DEV_PYTHON_PATH "${Python_SITELIB}")
endif()
install(TARGETS ${DEV_CMAKE_NAME}_python
    LIBRARY DESTINATION "${DEV_PYTHON_PATH}")