#######################
# Generate LICENSE.md #
#######################

# Generate LICENSE.md ("license" target)
devtemplate_configure_file(TARGET license INPUT "${PROJECT_SOURCE_DIR}/config/template/LICENSE.md" OUTPUT "${PROJECT_SOURCE_DIR}/LICENSE.md" ALL)
