#########################
# Packaging for Windows #
#########################

# Create windows folder
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/windows/${DEV_FILE_NAME}/usr")

# Define installer executables
add_executable(windows_installer WIN32 EXCLUDE_FROM_ALL)
add_executable(windows_packager EXCLUDE_FROM_ALL)

# Link installer resources
devtemplate_configure_file(OUTPUT "${PROJECT_BINARY_DIR}/windows/installer.exe.manifest"
    INPUT "${PROJECT_SOURCE_DIR}/config/template/installer.exe.manifest")
devtemplate_target_resource(TARGET windows_installer
    INPUT "executable/installer-win32.rc"
    DEPENDS "${PROJECT_BINARY_DIR}/windows/installer.exe.manifest" "icons/16-24-32-48-64-128-256.ico" "LICENSE.md")

# Define installer sources
target_sources(windows_installer PRIVATE "executable/installer-win32.cpp")
target_compile_definitions(windows_installer PRIVATE UNICODE)
target_compile_definitions(windows_installer PRIVATE
    ${DEV_MACRO_NAME}_NAME=${DEV_NAME}
    ${DEV_MACRO_NAME}_CMAKE_NAME=${DEV_CMAKE_NAME}
    ${DEV_MACRO_NAME}_FILE_NAME=${DEV_FILE_NAME}
    ${DEV_MACRO_NAME}_MACRO_NAME=${DEV_MACRO_NAME}
    ${DEV_MACRO_NAME}_MAJOR=${DEV_MAJOR}
    ${DEV_MACRO_NAME}_MINOR=${DEV_MINOR}
    ${DEV_MACRO_NAME}_PATCH=${DEV_PATCH}
    ${DEV_MACRO_NAME}_TYPE=${DEV_TYPE}
    ${DEV_MACRO_NAME}_${DEV_TYPE}
    ${DEV_MACRO_NAME}_DESCRIPTION=${DEV_DESCRIPTION}
    ${DEV_MACRO_NAME}_CATEGORY=${DEV_CATEGORY}
    ${DEV_MACRO_NAME}_HOMEPAGE=${DEV_HOMEPAGE}
    ${DEV_MACRO_NAME}_EMAIL=${DEV_EMAIL}
    ${DEV_MACRO_NAME}_AUTHOR=${DEV_AUTHOR})
    
target_sources(windows_packager PRIVATE "executable/packager-win32.cpp")
target_compile_definitions(windows_packager PRIVATE UNICODE)

# Define pre-packaging target
add_custom_target(windows_package DEPENDS ${DEV_PACKAGE_TARGETS} windows_installer windows_packager)