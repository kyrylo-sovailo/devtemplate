#########################
# Install Python script #
#########################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME}_python)
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}_python\" does not exist, cannot install Python script")
endif()

# Install Python script
install(PROGRAMS "${PROJECT_SOURCE_DIR}/python/executable.py"
    RENAME "${DEV_FILE_NAME}_executable.py"
    DESTINATION "${CMAKE_INSTALL_BINDIR}")