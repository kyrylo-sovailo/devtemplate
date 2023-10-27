##########################
# Install Python wrapper #
##########################

execute_process(COMMAND python3 "${PROJECT_SOURCE_DIR}/config/script/path.py" OUTPUT_VARIABLE DEV_PYTHON_PATH)
string(REGEX REPLACE "[\r\n]" "" DEV_PYTHON_PATH "${DEV_PYTHON_PATH}")

install(TARGETS ${DEV_CMAKE_NAME}_python
    LIBRARY DESTINATION "${DEV_PYTHON_PATH}")