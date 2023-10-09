set(PROJECT_SOURCE_DIR "${CMAKE_ARGV3}")
set(PROJECT_BINARY_DIR "${CMAKE_ARGV4}")
set(SOURCE "${PROJECT_SOURCE_DIR}/config/template/README.md")
set(SOURCE_ENV "${PROJECT_BINARY_DIR}/readme-environment.cmake")
set(DEST "${PROJECT_SOURCE_DIR}/README.md")
include("${SOURCE_ENV}")
file(REMOVE "${DEST}")
configure_file("${SOURCE}" "${DEST}")