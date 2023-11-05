###############################
# Install headers and targets #
###############################

# Dependencies
if (NOT TARGET ${DEV_CMAKE_NAME})
    message(FATAL_ERROR "Target \"${DEV_CMAKE_NAME}\" does not exist, cannot install library")
endif()

# Install headers
get_target_property(DEV_INTERFACE_SOURCES ${DEV_CMAKE_NAME} INTERFACE_SOURCES)
install(FILES "${DEV_INTERFACE_SOURCES}"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${DEV_FILE_NAME}")

# Install targets
install(TARGETS ${DEV_EXPORT_TARGETS}
    EXPORT ${DEV_CMAKE_NAME}_export
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${DEV_FILE_NAME}")
set(${DEV_CMAKE_NAME}_export TRUE)