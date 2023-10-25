#######################
# Install Python test #
#######################

install(PROGRAMS "${PROJECT_SOURCE_DIR}/python/test.py"
    RENAME "${DEV_FILE_NAME}_test.py"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")