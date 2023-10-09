# Uninstalling
add_custom_target(uninstall WORKING_DIRECTORY "${CMAKE_BUILD_DIR}" COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/misc/uninstall.cmake" ${DEV_CMAKE_NAME})