#######################
# Generate LICENSE.md #
#######################

# Generate LICENSE.md ("license" target)
devtemplate_configure_file(license TRUE "${PROJECT_SOURCE_DIR}/config/template/LICENSE.md" "${PROJECT_SOURCE_DIR}/LICENSE.md")
