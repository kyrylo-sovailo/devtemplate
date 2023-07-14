set(PROJECT_NAME "${CMAKE_ARGV3}")
file(STRINGS "install_manifest.txt" MANIFEST_FILE)
list(SORT MANIFEST_FILE)
set(PROTECTED "")
if (WIN32)
    set(PROTECTED "${PROTECTED}|.:[/\\]Program Files")
    set(PROTECTED "${PROTECTED}|.:[/\\]Program Files \(x86\)")
else()
    set(PROTECTED "${PROTECTED}|^/usr/(local/)?[^/]*$")
    set(PROTECTED "${PROTECTED}|^/usr/(local/)?share/[^/]*$")
    set(PROTECTED "${PROTECTED}|^/usr/(local/)?share/icons/[^/]*$")
    set(PROTECTED "${PROTECTED}|^/usr/(local/)?share/man/[^/]*$")
endif()

message(FATAL_ERROR "Danger! Not tested yet!")

# Removing files
set(MANIFEST "${MANIFEST_FILE}")
while(MANIFEST)
    list(POP_FRONT MANIFEST FILEPATH)
    get_filename_component(DIRPATH "${FILEPATH}" DIRECTORY)
    list(APPEND DIRPATHS "${DIRPATH}")
    if (EXISTS "${FILEPATH}")
        message("-- Uninstalling: ${FILEPATH}")
        file(REMOVE "${FILEPATH}")
        if (EXISTS "${FILEPATH}")
            message(WARNING "Could not delete ${FILEPATH}")
        endif()
    endif()
endwhile()

# Removing directories
list(REMOVE_DUPLICATES DIRPATHS)
while(DIRPATH)
    list(POP_FRONT DIRPATHS DIRPATH)
    if(NOT "${DIRPATH}" MATCHES "${PROTECTED}" AND EXISTS "${DIRPATH}")
        file(GLOB ENTRIES "${DIRPATH}/*")
        if (NOT ENTRIES)
            message("-- Uninstalling: ${DIRPATH}")
            file(REMOVE "${DIRPATH}")
            if (EXISTS "${DIRPATH}")
                message(WARNING "Could not delete ${DIRPATH}")
            endif()
            get_filename_component(DIRPATH "${DIRPATH}" DIRECTORY)
            list(APPEND DIRPATHS "${DIRPATH}")
            list(SORT DIRPATHS)
            list(REMOVE_DUPLICATES DIRPATHS)
        endif()
    endif()    
endwhile()