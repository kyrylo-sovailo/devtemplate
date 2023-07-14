# Header
cmake_minimum_required(VERSION 3.15)
project(devtemplate VERSION 0.0.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CMAKE_WARNING_FATAL False)

string(TOLOWER "${PROJECT_NAME}" PROJECT_NAME_LOWER)
set(DESCRIPTION "Template repository for C++/Python/CMake/Doxygen/VS Code stack")
set(AUTHOR "Kyrylo Sovailo")
set(EMAIL "k.sovailo@gmail.com")

# Generic features:
#include(config/header-only.cmake)
include(config/library.cmake)
include(config/executable.cmake)
include(config/executable-gui.cmake)
include(config/test.cmake)
include(config/documentation.cmake)
include(config/manual.cmake)
include(config/export.cmake)

# Installing generic features:
#include(config/install-header-only.cmake)
#include(config/install-library.cmake)
#include(config/install-executable.cmake)
#include(config/install-executable-gui.cmake)
#include(config/install-test.cmake)
#include(config/install-documentation.cmake)
#include(config/install-manual.cmake)
#include(config/install-cmake.cmake)
include(config/uninstall.cmake)

# Python:
#include(config/python-binding.cmake)
#include(config/python-executable.cmake)
#include(config/python-test.cmake)
#include(config/install-python-binding.cmake)
#include(config/install-python-executable.cmake)
#include(config/install-python-test.cmake)

# Packaging:
#include(config/package-rpm.cmake)      <-- package-rpm-bin     package-rpm-src     alias:package-rpm
#include(config/package-debian.cmake)   <-- package-debian-bin  package-debian-src  alias:package-debian
#include(config/package-tinycore.cmake) <-- package-tinycore-bin                    alias:package-tinycore
#include(config/package-arch.cmake)     <-- package-arch-bin    package-arch-src    alias:package-arch
#include(config/package-gentoo.cmake)   <-- package-gentoo-bin  package-gentoo-src  alias:package-gentoo package-gentoo-server
#include(config/package-windows.cmake)  <-- package-windows-bin                     alias:package-windows