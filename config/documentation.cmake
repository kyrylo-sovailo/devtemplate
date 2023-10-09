# Defining documentation generation
get_cmake_property(DEV_VARIABLES VARIABLES)
list (SORT DEV_VARIABLES)
file(WRITE "${PROJECT_BINARY_DIR}/variables.txt" "")
foreach (DEV_VARIABLE ${DEV_VARIABLES})
    file(APPEND "${PROJECT_BINARY_DIR}/variables.txt" "${DEV_VARIABLE}=${${DEV_VARIABLE}}\n")
endforeach()

#find_package(Doxygen REQUIRED)
#get_target_property(DEV_INTERFACE_SOURCES ${DEV_CMAKE_NAME} INTERFACE_SOURCES)
#list(JOIN DEV_INTERFACE_SOURCES " " DEV_INTERFACE_SOURCES)
#list(APPEND DEV_INTERFACE_SOURCES "${PROJECT_BINARY_DIR}/documentation.h")
#file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/documentation")
#configure_file("config/template/Doxyfile" "${PROJECT_BINARY_DIR}/Doxyfile")
#configure_file("config/template/documentation.h" "${PROJECT_BINARY_DIR}/documentation.h")

#

#
#
#add_custom_target(doc ALL COMMAND cmake -P "${CMAKE_SOURCE_DIR}/config/script/documentation.cmake")