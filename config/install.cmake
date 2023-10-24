###############################
# Install headers and targets #
###############################

# Install headers
get_target_property(DEV_INTERFACE_SOURCES ${DEV_CMAKE_NAME} INTERFACE_SOURCES)
install(FILES "${DEV_INTERFACE_SOURCES}"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${DEV_FILE_NAME}")

# Install targets
if (TARGET ${DEV_CMAKE_NAME})
    list(APPEND DEV_TARGETS ${DEV_CMAKE_NAME})
endif()
if (TARGET ${DEV_CMAKE_NAME}_executable)
    list(APPEND DEV_TARGETS ${DEV_CMAKE_NAME}_executable)
endif()
if (TARGET ${DEV_CMAKE_NAME}_executable_gui)
    list(APPEND DEV_TARGETS ${DEV_CMAKE_NAME}_executable_gui)
endif()
if (TARGET ${DEV_CMAKE_NAME}_test)
    list(APPEND DEV_TARGETS ${DEV_CMAKE_NAME}_test)
endif()
install(TARGETS ${DEV_TARGETS}
    EXPORT ${DEV_CMAKE_NAME}_export
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${DEV_FILE_NAME}")