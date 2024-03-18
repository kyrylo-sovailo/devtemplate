##########################
# Install Python wrapper #
##########################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME}_python)
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}_python\" does not exist, cannot install Python wrapper")
endif()

# Install Python wrapper
if (NOT WIN32)
    if ("${Python_SITELIB}" MATCHES "^/usr/")
        string(REGEX REPLACE "^/usr/" "" DEV_PYTHON_PATH "${Python_SITELIB}")
    else()
        set(DEV_PYTHON_PATH "${Python_SITELIB}")
    endif()
    install(TARGETS ${DEV_CMAKE_NAME}_python
        LIBRARY DESTINATION "${DEV_PYTHON_PATH}"
        ARCHIVE DESTINATION "${DEV_PYTHON_PATH}"
        RUNTIME DESTINATION "${DEV_PYTHON_PATH}")
else()
    install(FILES "$<TARGET_FILE:${DEV_CMAKE_NAME}_python>" TYPE BIN CONFIGURATIONS Release RENAME "${DEV_FILE_NAME}.pyd")
endif()