set(PROJECT_SOURCE_DIR "${CMAKE_ARGV3}")
set(PROJECT_BINARY_DIR "${CMAKE_ARGV4}")
execute_process(COMMAND doxygen "${PROJECT_BINARY_DIR}/Doxyfile" OUTPUT_QUIET)