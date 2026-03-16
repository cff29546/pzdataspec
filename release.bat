@echo off
setlocal enabledelayedexpansion
rem build release artifacts
rem usage: release.bat [target]

rem target can be a version number, "latest", or "clean". If not specified, all versions will be built.

set target=%1
set output_dir=%~dp0output\release\pzdataspec

if "%target%"=="clean" (
    rd /s /q "%output_dir%"
    exit /b
)

if "%target%"=="" (
    set target=all
)

rem find the latest version
set latest=0
for /d %%a in (%~dp0data_spec\spec\*) do (
    set dirname=%%~nxa
    rem check if the directory name is a number
    echo(!dirname!| findstr /r "^[0-9][0-9]*$" >nul
    if not errorlevel 1 (
        if !dirname! gtr !latest! set latest=!dirname!
    )
)
if %latest% gtr 0 set latest_version=%latest%

if "%target%"=="latest" (
    if "%latest_version%"=="" (
        echo No version found in spec directory.
        exit /b 1
    )
    set target=%latest_version%
)

if "%target%"=="all" (
    rem build all versions
    for /d %%a in (%~dp0data_spec\spec\*) do (
        set dirname=%%~nxa
        rem check if the directory name is a number
        echo(!dirname!| findstr /r "^[0-9][0-9]*$" >nul
        if not errorlevel 1 (
            call :build_single !dirname!
        )
    )
    python "%~dp0scripts\gen_release_notes.py" all
) else (
    rem build single version
    call :build_single %target%
    python "%~dp0scripts\gen_release_notes.py" %target%
)

goto :eof

:build_single
rem clear output directory
if exist "%output_dir%" rd /s /q "%output_dir%"
rem copy pzdataspec to output directory
xcopy "%~dp0pzdataspec" "%output_dir%" /y /e /i
rem build spec

call "%~dp0data_spec\build.bat" %1 -o "%output_dir%\spec"

rem pack output/release/pzdataspec to [version].zip
set version=%1
pushd "%~dp0output\release"
if exist pzdataspec-%version%.zip del pzdataspec-%version%.zip
powershell -Command "Compress-Archive -Path pzdataspec -DestinationPath pzdataspec-%version%.zip"
popd
exit /b

:eof