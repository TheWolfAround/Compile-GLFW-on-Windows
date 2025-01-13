@if not defined DevEnvDir (
    @if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build" (
        call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
    ) else (
        call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    )
)

@if not exist "%cd%\glfw" (
    git clone --depth 1 https://github.com/glfw/glfw.git --recursive
) else (
    echo glfw folder already exists.
)

@echo.
@echo off
set /P cmake_generator_type=Choose Cmake Generator (1 for Ninja, 2 for Visual Studio 17 2022):
if "%cmake_generator_type%"=="1" (
    set CMAKE_GENERATOR=Ninja
) else if "%cmake_generator_type%"=="2" (
    set CMAKE_GENERATOR="Visual Studio 17 2022"
) else (
    echo Invalid Cmake Generator. Please enter 1 or 2.
    exit /b 1
)
@echo.
echo Selected Cmake Generator: %CMAKE_GENERATOR%
@echo.

@echo.
@echo off
set /P build_choice=Choose build type (1 for Release, 2 for Debug):
if "%build_choice%"=="1" (
    set BUILD_TYPE=Release
    set COMPILE_FLAGS="/MP /O2 /arch:SSE4.2"
) else if "%build_choice%"=="2" (
    set BUILD_TYPE=Debug
    set COMPILE_FLAGS="/MP /Od"
) else (
    echo Invalid build_choice. Please enter 1 or 2.
    exit /b 1
)
@echo.
echo Selected build type: %BUILD_TYPE%
@echo.

@echo.
@echo off
set /P link_choice=Choose link type (1 for Static, 2 for Shared):
if "%link_choice%"=="1" (
    set LINK_TYPE=STATIC
) else if "%link_choice%"=="2" (
    set LINK_TYPE=SHARED
) else (
    echo Invalid link_choice. Please enter 1 or 2.
    exit /b 1
)
@echo.
echo Selected link type: %LINK_TYPE%
@echo.

set /P "=Press any to start compilation." <nul & pause >nul & echo(

set /a THREAD_COUNT = %NUMBER_OF_PROCESSORS% - 2

cmake -G %CMAKE_GENERATOR% ^
-D CMAKE_C_FLAGS=%COMPILE_FLAGS% ^
-D CMAKE_BUILD_TYPE=%BUILD_TYPE% ^
-D GLFW_BUILD_WIN32=ON ^
-D GLFW_LIBRARY_TYPE=%LINK_TYPE% ^
-D GLFW_BUILD_EXAMPLES=OFF ^
-D GLFW_BUILD_TESTS=OFF ^
-D GLFW_BUILD_DOCS=OFF ^
-S .\glfw ^
-B __build_dir__glfw__\%BUILD_TYPE%\%LINK_TYPE%

cmake --build __build_dir__glfw__\%BUILD_TYPE%\%LINK_TYPE% --config %BUILD_TYPE% -j%THREAD_COUNT%

:: end of file
