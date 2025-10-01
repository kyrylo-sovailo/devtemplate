################################################################################
# This project is developed with help of github.com/kyrylo-sovailo/devtemplate #
#                                    Header                                    #
################################################################################
set(DEV_NAME "Devtemplate")
string(TOLOWER "${DEV_NAME}" DEV_CMAKE_NAME)
string(TOLOWER "${DEV_NAME}" DEV_FILE_NAME)
string(TOUPPER "${DEV_NAME}" DEV_MACRO_NAME)
set(DEV_MAJOR 1)
set(DEV_MINOR 0)
set(DEV_PATCH 0)
set(DEV_TYPE SHARED)
set(DEV_CATEGORY 1)
set(DEV_HOMEPAGE "https://github.com/kyrylo-sovailo/devtemplate")
set(DEV_EMAIL "k.sovailo@gmail.com")
set(DEV_AUTHOR "Kyrylo Sovailo")
set(DEV_DESCRIPTION "Not Template repository for CMake/C++ stack")
set(DEV_EXTENDED_DESCRIPTION "Devtemplate is a minimalistic CMake-centered library that implements a lot features that many libraries have. It is a good starting point in devolvement of your own CMake/C++ library.")

cmake_minimum_required(VERSION 3.13)
project(${DEV_CMAKE_NAME} VERSION ${DEV_MAJOR}.${DEV_MINOR}.${DEV_PATCH} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
include(config/cmake/common.cmake)

####################
# Generic features #
####################
include(config/cmake/library.cmake)
include(config/cmake/executable.cmake)
include(config/cmake/executable-gui.cmake)
include(config/cmake/test.cmake)
include(config/cmake/documentation.cmake)
include(config/cmake/manual.cmake)
include(config/cmake/readme.cmake)
include(config/cmake/license.cmake)

###############################
# Installing generic features #
###############################
include(config/cmake/install-library.cmake)
include(config/cmake/install-cmake.cmake)
include(config/cmake/install-executable-gui.cmake)
include(config/cmake/install-documentation.cmake)
include(config/cmake/install-manual.cmake)
include(config/cmake/export.cmake)
include(config/cmake/uninstall.cmake)

##########
# Python #
##########
include(config/cmake/python-library.cmake)
include(config/cmake/python-executable.cmake)
include(config/cmake/python-test.cmake)
include(config/cmake/install-python-library.cmake)
include(config/cmake/install-python-executable.cmake)
include(config/cmake/install-python-test.cmake)

#############
# Packaging #
#############
add_custom_target(core DEPENDS ${DEV_CORE_TARGETS})
include(config/cmake/package-debian-binary.cmake)
include(config/cmake/package-debian-source.cmake)
include(config/cmake/package-windows.cmake)
#include(config/cmake/package-redhat.cmake)
#include(config/cmake/package-tinycore.cmake)
#include(config/cmake/package-arch.cmake)
#include(config/cmake/package-gentoo.cmake)