#########################
# Packaging for Windows #
#########################

# Create windows folder
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/windows/${DEV_FILE_NAME}/usr")

# Define installer executable
add_executable(windows_installer WIN32 EXCLUDE_FROM_ALL)

# Link installer resources
devtemplate_configure_file(TARGET windows_installer_manifest
    INPUT "${PROJECT_SOURCE_DIR}/config/template/installer.exe.manifest"
    OUTPUT "${PROJECT_BINARY_DIR}/windows/installer.exe.manifest")
devtemplate_compile_resource(TARGET windows_installer
    RESOURCE_TARGET windows_installer_resource
    INPUT "executable/installer-win32.rc"
    DEPENDS windows_installer_manifest)

# Define installer sources
target_sources(windows_installer PRIVATE "executable/installer-win32.cpp")
target_compile_definitions(windows_installer PRIVATE UNICODE)

# Define pre-packaging target
add_custom_target(windows_package DEPENDS ${DEV_PACKAGE_TARGETS} windows_installer)