################################
# Generate of VS Code settings #
################################

# Dependencies
if ((NOT TARGET ${DEV_CMAKE_NAME}_executable) AND (NOT EXISTS "${PROJECT_SOURCE_DIR}/python/executable.py"))
    message(FATAL_ERROR "Both target \"${DEV_CMAKE_NAME}_executable\" and file \"python/executable.py\" do not exist, cannot generate debugging configuration")
endif()

# Define debug targets
file(RELATIVE_PATH DEV_RELATIVE_PATH "${PROJECT_SOURCE_DIR}" "${PROJECT_BINARY_DIR}")
set(DEV_VSCODE_SOURCE_DIR "\\\$\{workspaceFolder\}")
set(DEV_VSCODE_BINARY_DIR "\\\$\{workspaceFolder\}/${DEV_RELATIVE_PATH}")

set(DEV_DEBUG_TARGET "${DEV_VSCODE_BINARY_DIR}/${DEV_CMAKE_NAME}")
set(DEV_DEBUG_DIRECTORY "${DEV_VSCODE_BINARY_DIR}")
set(DEV_DEBUG_ARGUMENTS "")
set(DEV_DEBUG_PYTHON_TARGET "${DEV_VSCODE_SOURCE_DIR}/python/executable.py")
set(DEV_DEBUG_PYTHON_DIRECTORY "${DEV_VSCODE_BINARY_DIR}")
set(DEV_DEBUG_PYTHON_ARGUMENTS "")

# Define variables for tasks.json/launch.json
get_property(DEV_GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if (DEV_GENERATOR_IS_MULTI_CONFIG)
    set(DEV_TASKS_CONFIGURE_ARGUMENTS "\\\"${DEV_VSCODE_SOURCE_DIR}\\\"")
    set(DEV_TASKS_BUILD_ARGUMENTS "--build, \\\"${DEV_VSCODE_BINARY_DIR}\\\", --config, Debug")
else()
    set(DEV_TASKS_CONFIGURE_ARGUMENTS "\\\"${DEV_VSCODE_SOURCE_DIR}\\\", -DCMAKE_BUILD_TYPE=Debug")
    set(DEV_TASKS_BUILD_ARGUMENTS "--build, \\\"${DEV_VSCODE_BINARY_DIR}\\\"")
endif()
set(DEV_TASKS_CONFIGURE_DIRECTORY "${DEV_BEGIN}/${DEV_RELATIVE_PATH}${DEV_END}")
set(DEV_TASKS_BUILD_DIRECTORY "${DEV_BEGIN}/${DEV_RELATIVE_PATH}${DEV_END}")

# Generate tasks.json
devtemplate_configure_file(${DEV_CMAKE_NAME}_tasks FALSE "${PROJECT_SOURCE_DIR}/config/template/tasks.json" "${PROJECT_SOURCE_DIR}/.vscode/tasks.json")

# Generate launch.json
devtemplate_configure_file(${DEV_CMAKE_NAME}_launch FALSE "${PROJECT_SOURCE_DIR}/config/template/launch.json" "${PROJECT_SOURCE_DIR}/.vscode/launch.json")

# Define "vscode" target
add_custom_target(vscode)
add_dependencies(vscode ${DEV_CMAKE_NAME}_tasks ${DEV_CMAKE_NAME}_launch)