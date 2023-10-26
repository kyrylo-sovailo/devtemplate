set(PROJECT_BINARY_DIR "${CMAKE_ARGV3}")
set(DEV_ROOT_DIR "${CMAKE_ARGV4}")
set(DEV_PRETEND False)

# Get list of installed files
file(STRINGS "${PROJECT_BINARY_DIR}/install_manifest.txt" DEV_FILEPATHS)
list(SORT DEV_FILEPATHS ORDER DESCENDING)

# Get list of files and directories
file(GLOB_RECURSE DEV_ENTRIES LIST_DIRECTORIES True "${DEV_ROOT_DIR}/*")
list(SORT DEV_ENTRIES ORDER DESCENDING)

# Remove files and directories
foreach (DEV_ENTRY ${DEV_ENTRIES})
    if (NOT "${DEV_ENTRY}" STREQUAL "${DEV_ROOT_DIR}/control")
        set (DEV_DELETE True)
        foreach (DEV_FILEPATH ${DEV_FILEPATHS})
            if ("${DEV_FILEPATH}" MATCHES "^${DEV_ENTRY}")
                set (DEV_DELETE False)
                break()
            endif()
        endforeach()
        if (DEV_DELETE)
            message("-- Cleaning: ${DEV_ENTRY}")
            if (NOT DEV_PRETEND)
                file(REMOVE_RECURSE "${DEV_ENTRY}")
                if (EXISTS "${DEV_ENTRY}")
                    message(WARNING "Could not remove ${DEV_ENTRY}")
                endif()
            endif()
        endif()
    endif()
endforeach()