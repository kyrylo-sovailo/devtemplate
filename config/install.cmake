###############################
# Install library and headers #
###############################

# Install headers
install(FILES "${DEV_RELATIVE_SOURCES}"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")

# Install library
install(TARGETS ${DEV_CMAKE_NAME}
    EXPORT ${DEV_CMAKE_NAME}_export
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${DEV_FILE_NAME}")