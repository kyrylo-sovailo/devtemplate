############################
# Define uninstall command #
############################

add_custom_target(uninstall COMMAND cmake -P "${PROJECT_SOURCE_DIR}/config/script/uninstall.cmake" "${PROJECT_BINARY_DIR}")