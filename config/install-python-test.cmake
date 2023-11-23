#######################
# Install Python test #
#######################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME}_python)
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}_python\" does not exist, cannot install Python test script")
endif()

# Install Python test script
install(PROGRAMS "${PROJECT_SOURCE_DIR}/python/test.py"
    RENAME "${DEV_FILE_NAME}_test.py"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")