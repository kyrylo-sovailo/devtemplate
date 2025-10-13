# Messages
export ERROR="\033[01;31m${SCRIPT}: "
export PROGRESS="\033[01;35m${SCRIPT}: "
export RESET="\033[0m\n"

# Check arguments
DEV_ERROR=0
if [   -z "$0" ]; then DEV_ERROR=1; fi  #If script path is empty
if [ ! -f "$0" ]; then DEV_ERROR=1; fi  #If script does not exist
if [   -z "$1" ]; then DEV_ERROR=1; fi  #If binary directory is empty
if [ ! -d "$1" ]; then DEV_ERROR=1; fi  #If script directory does not exist
if [   -n "$2" ]; then DEV_ERROR=1; fi  #If other arguments are given
if [ ${DEV_ERROR} -ne 0 ]; then printf "${ERROR}Usage: ${SCRIPT} <path to cmake binary directory>${RESET}"; exit 1; fi

# Find source and binary directories
export DEV_BINARY_DIR=$(readlink -f "$1")
DEV_SOURCE_DIR=$(readlink -f "$0")
DEV_SOURCE_DIR=$(dirname "${DEV_SOURCE_DIR}")
DEV_SOURCE_DIR=$(dirname "${DEV_SOURCE_DIR}")
export DEV_SOURCE_DIR=$(dirname "${DEV_SOURCE_DIR}")

# Initial CMake configuration
if [ ! -f "${DEV_BINARY_DIR}/CMakeCache.txt" ]; then
    printf "${PROGRESS}(cd \"${DEV_BINARY_DIR}\" && cmake \"${DEV_SOURCE_DIR}\")${RESET}"
    (cd "${DEV_BINARY_DIR}" && cmake "${DEV_SOURCE_DIR}")
    if [ $? -ne 0 ]; then printf "${ERROR}CMake configuration failed${RESET}"; exit 1; fi
fi

# Getting package and CMake information
printf "${PROGRESS}cmake --build \"${DEV_BINARY_DIR}\" --target environment_sh${RESET}"
cmake --build "${DEV_BINARY_DIR}" --target environment_sh
if [ $? -ne 0 ]; then printf "${ERROR}CMake target \"environment\" failed${RESET}"; exit 1; fi
printf "${PROGRESS}source \"${DEV_BINARY_DIR}/environment.sh\"${RESET}"
source "${DEV_BINARY_DIR}/environment.sh"
if [ $? -ne 0 ]; then printf "${ERROR}Reading environment failed${RESET}"; exit 1; fi

# Decide if --install/--prefix is implemented
if [ ${DEV_CMAKE_MAJOR} -lt 3 ]; then export DEV_CMAKE_CAN_INSTALL=0
elif [ ${DEV_CMAKE_MAJOR} -gt 3 ]; then export DEV_CMAKE_CAN_INSTALL=1
elif [ ${DEV_CMAKE_MINOR} -ge 15 ]; then export DEV_CMAKE_CAN_INSTALL=1
else export DEV_CMAKE_CAN_INSTALL=0
fi

# Checks if tar.gz file is up to date and generates it if not
update_tar() {
    DEV_TAR_PATH="$1"
    DEV_SOURCE_DIR="$2"
    DEV_BINARY_DIR="$3"

    case "${DEV_BINARY_DIR}" in
        ("${DEV_SOURCE_DIR}"/*)    
            DEV_RELATIVE_BINARY_DIR=$(realpath "${DEV_BINARY_DIR}" --relative-to="${DEV_SOURCE_DIR}")
            ;;
        (*)
            DEV_RELATIVE_BINARY_DIR=
            ;;
    esac

    DEV_CHANGES=0
    if [ ! -f "$1" ]; then DEV_CHANGES=1; fi #File does not exist
    if [ ${DEV_CHANGES} -eq 0 ]; then #Source files newer then the archive
        if [ -n "${DEV_RELATIVE_BINARY_DIR}" ]; then
            DEV_CHANGES=$(cd "${DEV_SOURCE_DIR}" && find -type f -newer "${DEV_TAR_PATH}" ! -regex '^./[^/]*.md$' ! -regex '^./[^/]*Config.cmake$' ! -wholename '*/.*' ! -wholename "./${DEV_RELATIVE_BINARY_DIR}/*" | wc -l)
        else
            DEV_CHANGES=$(cd "${DEV_SOURCE_DIR}" && find -type f -newer "${DEV_TAR_PATH}" ! -regex '^./[^/]*.md$' ! -regex '^./[^/]*Config.cmake$' ! -wholename '*/.*' | wc -l)
        fi
    fi
    if [ ${DEV_CHANGES} -eq 0 ]; then #List of source files does not match the archive
        if [ -n "${DEV_RELATIVE_BINARY_DIR}" ]; then
            DEV_LIST=$(cd "${DEV_SOURCE_DIR}" && find -type f ! -regex '^./[^/]*.md$' ! -regex '^./[^/]*Config.cmake$' ! -wholename '*/.*' ! -wholename "./${DEV_RELATIVE_BINARY_DIR}/*" | sort)
        else
            DEV_LIST=$(cd "${DEV_SOURCE_DIR}" && find -type f ! -regex '^./[^/]*.md$' ! -regex '^./[^/]*Config.cmake$' ! -wholename '*/.*' | sort)
        fi
        DEV_ARCHIVE=$(tar --list --file "${DEV_TAR_PATH}" | sort | grep -v '/$')
        if [ "${DEV_LIST}" != "${DEV_ARCHIVE}" ]; then
            DEV_CHANGES=1
        fi
    fi

    if [ ${DEV_CHANGES} -ne 0 ]; then
        if [ -n "${DEV_RELATIVE_BINARY_DIR}" ]; then
            printf "${PROGRESS}(cd \"${DEV_SOURCE_DIR}\" && tar --create --gzip --no-wildcards-match-slash --file \"${DEV_TAR_PATH}\" --transform=\"s|^\./|${DEV_FILE_NAME}-${DEV_VERSION}/|\" --exclude='./*.md' --exclude='./*Config.cmake' --exclude='./.*' --exclude=\"./${DEV_RELATIVE_BINARY_DIR}/*\" .)${RESET}"
            (cd "${DEV_SOURCE_DIR}" && tar --create --gzip --no-wildcards-match-slash --file "${DEV_TAR_PATH}" --transform="s|^\./|${DEV_FILE_NAME}-${DEV_VERSION}/|" --exclude='./*.md' --exclude='./*Config.cmake' --exclude='./.*' --exclude="./${DEV_RELATIVE_BINARY_DIR}/*" .)
        else
            printf "${PROGRESS}(cd \"${DEV_SOURCE_DIR}\" && tar --create --gzip --no-wildcards-match-slash --file \"${DEV_TAR_PATH}\" --transform=\"s|^\./|${DEV_FILE_NAME}-${DEV_VERSION}/|\" --exclude='./*.md' --exclude='./*Config.cmake' --exclude='./.*' .)${RESET}"
            (cd "${DEV_SOURCE_DIR}" && tar --create --gzip --no-wildcards-match-slash --file "${DEV_TAR_PATH}" --transform="s|^\./|${DEV_FILE_NAME}-${DEV_VERSION}/|" --exclude='./*.md' --exclude='./*Config.cmake' --exclude='./.*' .)
        fi
        if [ $? -ne 0 ]; then printf "${ERROR}Tarball creation failed${RESET}"; exit 1; fi
    fi
    return ${DEV_CHANGES}
}
export -f update_tar