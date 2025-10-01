# This script reads the environment file, defines time-related variables (not part if the environment) and configures the file
# Arguments: SOURCE SOURCE_ENVIRONMENT DESTINATION

# Parsing arguments
set(SOURCE "${CMAKE_ARGV3}")
set(SOURCE_ENVIRONMENT "${CMAKE_ARGV4}")
set(DESTINATION "${CMAKE_ARGV5}")

# Setting environment
string(TIMESTAMP DEV_TIMESTAMP "%Y;%B;%b;%d;%a;%H;%M;%S" UTC)
list(GET DEV_TIMESTAMP 0 DEV_YEAR)
list(GET DEV_TIMESTAMP 1 DEV_MONTH)
list(GET DEV_TIMESTAMP 2 DEV_MONTH3)
list(GET DEV_TIMESTAMP 3 DEV_DAY)
list(GET DEV_TIMESTAMP 4 DEV_WEEKDAY)
list(GET DEV_TIMESTAMP 5 DEV_HOUR)
list(GET DEV_TIMESTAMP 6 DEV_MINUTE)
list(GET DEV_TIMESTAMP 7 DEV_SECOND)
set(DEV_TIMESTAMP "${DEV_WEEKDAY}, ${DEV_DAY} ${DEV_MONTH3} ${DEV_YEAR} ${DEV_HOUR}:${DEV_MINUTE}:${DEV_SECOND}")

include("${SOURCE_ENVIRONMENT}")

# Configuring
file(REMOVE "${DESTINATION}")
configure_file("${SOURCE}" "${DESTINATION}")