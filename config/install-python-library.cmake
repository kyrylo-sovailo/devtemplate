##########################
# Install Python wrapper #
##########################

install(TARGETS ${DEV_CMAKE_NAME}_python
    LIBRARY DESTINATION "lib/python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}/site-packages")