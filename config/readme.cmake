######################
# Generate README.md #
######################

# Generate README.md ("readme" target)
devtemplate_configure_file(OUTPUT "${PROJECT_SOURCE_DIR}/README.md" INPUT "${PROJECT_SOURCE_DIR}/config/template/README.md")
add_custom_target(readme ALL DEPENDS "${PROJECT_SOURCE_DIR}/README.md")