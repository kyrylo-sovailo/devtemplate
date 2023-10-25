#########################
# Install Python script #
#########################

install(PROGRAMS "${PROJECT_SOURCE_DIR}/python/executable.py"
    RENAME "${DEV_FILE_NAME}_executable.py"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")