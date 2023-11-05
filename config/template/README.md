# Welcome to ${DEV_NAME} v${DEV_MAJOR}.${DEV_MINOR}.${DEV_PATCH}

${DEV_DESCRIPTION}

#### What this library is?
 - Devtemplate is a minimalistic CMake-centered library that implements a lot features that many libraries have. It is a good starting point in developement of your own CMake/C++ library.
 - Devtemplate also provides modules and scripts for packaging the library. Their goal is to help you (and potential users of your library) to install and uninstall the library in a way that is more handy and safe than pure CMake.

#### What this library is not?
 - Devtemplate is not a generator of CMake scripts (because it would be too meta)
 - Devtemplate is not a one-fit-all template (because these don't exist)
 - Devtemplate is not a reference implementation (it's not the fastest, not the cleanest, not the most minimal)
 - Devtemplate is not a cross-compilation library (unless you know what you are doing)

#### Features
 - Build process automation
 - Installation and uninstallation
 - Graphical icons
 - Documentation and manual
 - Python bindings
 - Packaging for different operative systems
 - etc.

#### Suported operative systems
 - Deabian (binary `.deb` files)

#### How to use
 1. Clone the repository.
 2. Rename `devtemplate` in `CMakeLists.txt` to something else.
 3. Disable unneeded modules, delete unneeded files, get rid of unneeded functionality
 4. Replace existing code with your own. Change the list of source files and headers in correspondent `config/*.cmake` files.
 5. Change templates of manifest files in `config/template`. Package dependencies are to be filled in manually!
 6. Run `config/package/<os-name>.sh` script to produce a package file native to the selected operative system

#### Generated on ${DEV_TIMESTAMP}
