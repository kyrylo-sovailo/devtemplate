# Uninstalling
add_custom_target(uninstall WORKING_DIRECTORY "${CMAKE_BUILD_DIR}" COMMAND cmake -P "${CMAKE_SOURCE_DIR}/config/misc/uninstall.cmake" ${PROJECT_NAME})