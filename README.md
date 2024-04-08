# Welcome to Devtemplate v0.0.0

Template repository for CMake/C++ stack

### What this library is?
 - Devtemplate is a minimalist CMake-centered library that implements a lot features that many libraries have. It is a good starting point in development of your own CMake/C++ library.
 - Devtemplate is an ultimate CMake cheat sheet.
 - Devtemplate also provides modules and scripts for packaging the library. Their goal is to help you (and potential users of your library) to install and uninstall the library in a way that is more handy and safe than pure CMake.

### What this library is not?
 - Devtemplate is not a generator of CMake scripts (because it would be too meta)
 - Devtemplate is not a one-fit-all template (because these don't exist)
 - Devtemplate is not a reference implementation (it's not the fastest, not the cleanest, not the most minimal)
 - Devtemplate is not a cross-compilation library (unless you know what you are doing)

### Features
 - Build process automation
 - Installation and uninstallation
 - Graphical icons
 - Documentation and manual
 - Python bindings
 - Packaging for different operative systems
 - etc.

### Supported operative systems
 - Debian (binary `.deb` files)

### Troubleshooting
 - `Mismatch detected for 'RuntimeLibrary'`

This is a Windows-specific problem that exists because some of the libraries you are trying to link (most probably GTest) were compiled and linked with different options. There are two options: either you recompile the library in question (add `-Dgtest_force_shared_crt` in case of GTest) or you may force specific runtime library for Devtemplate by setting `-DDEV_FORCE_CRT=<static|dynamic>_<release|debug>` (`static_release` should help in case of GTest).

 - Executable has no icons
 
Under Linux the executables has no compiled-in icons at all, and no file manager can associate the executable with the icons. The icons become visible only after proper installation.

Under Windows the icons are compiled into executables, but this compilation is compiler-specific. If you are not seeing items, it means that your compiler is not supported.

### How to use
 1. Clone the repository.
 2. Rename `devtemplate` in `CMakeLists.txt` to something else.
 3. Disable unneeded modules, delete unneeded files, get rid of unneeded functionality
 4. Replace existing code with your own. Change the list of source files and headers in correspondent `config/<module-name>.cmake` files.
 5. Change templates of manifest files in `config/template`. Package dependencies are to be filled in manually!
 6. Run `config/package/<os-name>.sh` script to produce a package file native to the selected operative system

### Generated on Mon, 08 Apr 2024 15:37:55 UTC
