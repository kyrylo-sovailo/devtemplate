# Defining manual generation
string(TIMESTAMP DATE "%d %B %Y" UTC)
configure_file("config/misc/man" "${PROJECT_BINARY_DIR}/man")
add_custom_target(man COMMAND gzip "${PROJECT_BINARY_DIR}/man" --stdout > "${PROJECT_BINARY_DIR}/man.1")