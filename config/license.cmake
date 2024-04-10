#######################
# Generate LICENSE.md #
#######################

# Generate LICENSE.md ("license" target)
devtemplate_configure_file(OUTPUT "${PROJECT_SOURCE_DIR}/LICENSE.md" INPUT "${PROJECT_SOURCE_DIR}/config/template/LICENSE.md")
add_custom_target(license ALL DEPENDS "${PROJECT_SOURCE_DIR}/LICENSE.md")
