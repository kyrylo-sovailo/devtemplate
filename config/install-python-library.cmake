##########################
# Install Python wrapper #
##########################

execute_process(COMMAND python3 -V OUTPUT_VARIABLE DEV_PYTHON_VERSION)
string(REGEX REPLACE "[ \.]+" ";" DEV_PYTHON_VERSION "${DEV_PYTHON_VERSION}")
list(GET DEV_PYTHON_VERSION 1 DEV_PYTHON_MAJOR)
list(GET DEV_PYTHON_VERSION 2 DEV_PYTHON_MINOR)

install(TARGETS ${DEV_CMAKE_NAME}_python
    LIBRARY DESTINATION "lib/python${DEV_PYTHON_MAJOR}.${DEV_PYTHON_MINOR}/site-packages")