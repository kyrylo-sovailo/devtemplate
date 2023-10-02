################################################################################
# This project is developed with help of github.com/kyrylo-sovailo/devtemplate #
#                                    Header                                    #
################################################################################
set(DEV_FRIENDLY_NAME "Devtemplate")
set(DEV_NAME "devtemplate")
set(DEV_DESCRIPTION "Template repository for CMake/C++ stack")
set(DEV_AUTHOR "Kyrylo Sovailo")
set(DEV_EMAIL "k.sovailo@gmail.com")
set(DEV_VERSION "0.0.0")

cmake_minimum_required(VERSION 3.15)
project(${DEV_NAME} VERSION ${DEV_VERSION} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_WARNING_FATAL False)

####################
# Generic features #
####################
#include(config/header-library.cmake)
include(config/library.cmake)
include(config/executable.cmake)
include(config/executable-gui.cmake)
#include(config/test.cmake)
#include(config/documentation.cmake)
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