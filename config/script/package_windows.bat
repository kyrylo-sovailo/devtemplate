@echo off
setlocal
set /A DEV_ERROR=0

REM Check arguments
if "%0" == ""       ( set /A DEV_ERROR=1 )
if not exist "%0"   ( set /A DEV_ERROR=1 )
if "%1" == ""       ( set /A DEV_ERROR=1 )
if not exist "%1"   ( set /A DEV_ERROR=1 )
if not "%2" == ""   ( set /A DEV_ERROR=1 )
pushd "%1"
set DEV_BINARY_DIR=%cd%
popd
pushd "%~dp0"
cd ..\..
set DEV_SOURCE_DIR=%cd%
popd
if errorlevel 1 set /A DEV_ERROR=1
if not "%DEV_ERROR%" == "0" (
    echo windows.bat usage: .\windows.bat ^<path to cmake binary directory^>
    exit /b 1
)

REM Initial CMake configuration
for /F "tokens=3" %%I in ('cmake --version') do (
    set DEV_CMAKE_VERSION=%%I
    goto endfor1
)
:endfor1
if errorlevel 1 set /A DEV_ERROR=1
for /F "tokens=1,2,3 delims=.-" %%I in ('echo %DEV_CMAKE_VERSION%') do (
    set /A DEV_CMAKE_MAJOR=%%I
    set /A DEV_CMAKE_MINOR=%%J
    set /A DEV_CMAKE_PATCH=%%K
    goto endfor2
)
:endfor2
if errorlevel 1 set /A DEV_ERROR=1
if not "%DEV_ERROR%" == "0" (
    echo windows.bat: could not get CMake version
    exit /b 1
)

REM Initial CMake configuration
cd "%DEV_BINARY_DIR%"
if not exist "%DEV_BINARY_DIR%/windows" (
    cmake "%DEV_SOURCE_DIR%"
    if errorlevel 1 (
        echo windows.bat: initial CMake configuration failed
        exit /b 1
    )
)
set DEV_INSTALL_ROOT="%DEV_BINARY_DIR%/windows"

REM Secondary CMake configuration, build and installation
if %DEV_CMAKE_MAJOR% LSS 3 (
    set /A DEV_NEW=0
) else (
    if %DEV_CMAKE_MAJOR% GTR 3 (
        set /A DEV_NEW=1
    ) else (
        if %DEV_CMAKE_MINOR% GEQ 15 (
            set /A DEV_NEW=1
        ) else (
            set /A DEV_NEW=0
        )
    )
)

if %DEV_NEW% GTR 0 (
    cmake --build "%DEV_BINARY_DIR%" --target package_windows
    if errorlevel 1 (
        echo windows.bat: building target package_windows failed
        exit /b 1
    )
    cmake --install "%DEV_BINARY_DIR%" --prefix "%DEV_INSTALL_ROOT%"
    if errorlevel 1 (
        echo windows.bat: installation to local directory failed
        exit /b 1
    )
) else (
    cmake -DCMAKE_INSTALL_PREFIX:PATH="%DEV_INSTALL_ROOT%" "%DEV_SOURCE_DIR%"
    if errorlevel 1 (
        echo windows.bat: CMake configuration failed
        exit /b 1
    )
    cmake --build "%DEV_BINARY_DIR%" --target package_windows
    if errorlevel 1 (
        echo windows.bat: building target package_windows failed
        exit /b 1
    )
    cmake --build "%DEV_BINARY_DIR%" --target install
    if errorlevel 1 (
        echo windows.bat: installation to local directory failed
        exit /b 1
    )
)

echo Success