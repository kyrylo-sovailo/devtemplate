#######################################
# Creating source packages for Gentoo #
#######################################

# Create gentoo_source folder
file(MAKE_DIRECTORY "${PROJECT_BINARY_DIR}/gentoo_source")

# Generate ebuild file
devtemplate_configure_file(${DEV_CMAKE_NAME}_gentoo_source_ebuild FALSE "${PROJECT_SOURCE_DIR}/config/template/gentoo_source/skel.ebuild" "${PROJECT_BINARY_DIR}/gentoo_source/${DEV_FILE_NAME}-${DEV_VERSION}.ebuild")

# Generate metadata file
devtemplate_configure_file(${DEV_CMAKE_NAME}_gentoo_source_metadata FALSE "${PROJECT_SOURCE_DIR}/config/template/gentoo_source/skel.metadata.xml" "${PROJECT_BINARY_DIR}/gentoo_source/metadata.xml")

# Define pre-packaging target
add_custom_target(package_gentoo_source DEPENDS ${DEV_CMAKE_NAME}_gentoo_source_ebuild ${DEV_CMAKE_NAME}_gentoo_source_metadata)
