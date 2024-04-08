######################
# Generate README.md #
######################

# Generate README.md ("readme" target)
devtemplate_configure_file(TARGET readme INPUT "${PROJECT_SOURCE_DIR}/config/template/README.md" OUTPUT "${PROJECT_SOURCE_DIR}/README.md" ALL)
