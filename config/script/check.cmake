set(PROJECT_BINARY_DIR "${CMAKE_ARGV4}")
set(DEV_INSTALL_ROOT "${CMAKE_ARGV5}")
set(DEV_PACKAGE_FILE "${CMAKE_ARGV6}")
set(DEV_PRETEND False)

set(DEV_PROTECTED "DEBIAN(/control)?$")

# Get list of installed files and directories
file(STRINGS "${PROJECT_BINARY_DIR}/install_manifest.txt" DEV_FILEPATHS)
list(SORT DEV_FILEPATHS ORDER DESCENDING)
foreach (DEV_FILEPATH IN LISTS DEV_FILEPATHS)
    if (NOT EXISTS "${DEV_FILEPATH}")
        message(FATAL_ERROR "File ${DEV_FILEPATH} is missing")
    endif()
    if ("${DEV_FILEPATH}" IS_NEWER_THAN "${DEV_PACKAGE_FILE}")
        set(DEV_CHANGED True)
    endif()

    set(DEV_OLD_DIRPATH "${DEV_FILEPATH}")
    get_filename_component(DEV_DIRPATH "${DEV_FILEPATH}" DIRECTORY)
    list(APPEND DEV_DIRPATHS "${DEV_DIRPATH}")
    while ((NOT "${DEV_DIRPATH}" STREQUAL "${DEV_INSTALL_ROOT}") AND (NOT "${DEV_DIRPATH}" STREQUAL "${DEV_OLD_DIRPATH}"))
        set(DEV_OLD_DIRPATH "${DEV_DIRPATH}")
        get_filename_component(DEV_DIRPATH "${DEV_DIRPATH}" DIRECTORY)
        list(APPEND DEV_DIRPATHS "${DEV_DIRPATH}")
    endwhile()
endforeach()
list(SORT DEV_DIRPATHS ORDER DESCENDING)
list(REMOVE_DUPLICATES DEV_DIRPATHS)

# Get list of all files and directories
file(GLOB_RECURSE DEV_ENTRIES LIST_DIRECTORIES True "${DEV_INSTALL_ROOT}/*")
list(SORT DEV_ENTRIES ORDER DESCENDING)

# Remove files and directories
cmake_policy(SET CMP0057 NEW)
foreach (DEV_ENTRY IN LISTS DEV_ENTRIES)
    if ("${DEV_ENTRY}" MATCHES "${DEV_PROTECTED}")
        continue()
    endif()

    if ((NOT "${DEV_ENTRY}" IN_LIST DEV_DIRPATHS) AND (NOT "${DEV_ENTRY}" IN_LIST DEV_FILEPATHS))
        message("-- Cleaning: ${DEV_ENTRY}")
        set(DEV_CHANGED True)
        if (NOT DEV_PRETEND)
            file(REMOVE_RECURSE "${DEV_ENTRY}")
            if (EXISTS "${DEV_ENTRY}")
                message(WARNING "Could not remove ${DEV_ENTRY}")
            endif()
        endif()
    endif()
endforeach()

# Remove packaged file
if (DEV_CHANGED)
    file(REMOVE "${DEV_PACKAGE_FILE}")
endif()