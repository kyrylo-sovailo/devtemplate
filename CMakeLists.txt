################################################################################
# This project is developed with help of github.com/kyrylo-sovailo/devtemplate #
#                                    Header                                    #
################################################################################
set(DEV_NAME "Devtemplate")
string(TOLOWER "${DEV_NAME}" DEV_CMAKE_NAME)
string(TOLOWER "${DEV_NAME}" DEV_FILE_NAME)
string(TOUPPER "${DEV_NAME}" DEV_MACRO_NAME)
set(DEV_MAJOR 0)
set(DEV_MINOR 0)
set(DEV_PATCH 0)
set(DEV_TYPE SHARED)
set(DEV_DESCRIPTION "Template repository for CMake/C++ stack")
set(DEV_HOMEPAGE "github.com/kyrylo-sovailo/devtemplate")
set(DEV_EMAIL "k.sovailo@gmail.com")
set(DEV_AUTHOR "Kyrylo Sovailo")

cmake_minimum_required(VERSION 3.15)
project(${DEV_CMAKE_NAME} VERSION ${DEV_MAJOR}.${DEV_MINOR}.${DEV_PATCH} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

####################
# Generic features #
####################
include(config/library.cmake)
include(config/executable.cmake)
include(config/executable-gui.cmake)
include(config/test.cmake)
include(config/readme.cmake)
include(config/documentation.cmake)
#include(config/manual.cmake)
#include(config/export.cmake)

###############################
# Installing generic features #
###############################
#include(config/install-header-library.cmake)
#include(config/install-library.cmake)
#include(config/install-executable.cmake)
#include(config/install-executable-gui.cmake)
#include(config/install-test.cmake)
#include(config/install-documentation.cmake)
#include(config/install-manual.cmake)
#include(config/install-cmake.cmake)
#include(config/uninstall.cmake)

##########
# Python #
##########
#include(config/python-library.cmake)
#include(config/python-executable.cmake)
#include(config/python-test.cmake)
#include(config/install-python-library.cmake)
#include(config/install-python-executable.cmake)
#include(config/install-python-test.cmake)

#############
# Packaging #
#############
#include(config/package-rpm.cmake)
#include(config/package-debian.cmake)
#include(config/package-tinycore.cmake)
#include(config/package-arch.cmake)
#include(config/package-gentoo.cmake)
#include(config/package-windows.cmake)
#include(config/package-all.cmake)