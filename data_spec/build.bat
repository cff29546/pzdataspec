@echo off
setlocal enabledelayedexpansion
rem arg1: either a version number or a path to a .ksy file
rem optional: -o output_dir to set output directory for generated python files
rem compatibility: arg2 is still treated as output_dir when -o is not used
rem if arg1 is omitted, the latest version is used
set target=%1
set output_dir=

if /i "%1"=="-o" (
    set target=
    set output_dir=%~2
) else (
    if /i "%2"=="-o" (
        set output_dir=%~3
    ) else (
        set output_dir=%~2
    )
)

if not "%output_dir%"=="" set output_dir=%output_dir:"=%

if "%output_dir%"=="" set output_dir=%~dp0\..\output\spec
rem find the latest version
set ver=0
for /d %%a in (%~dp0spec\*) do (
    set dirname=%%~nxa
    rem check if the directory name is a number
    echo(!dirname!| findstr /r "^[0-9][0-9]*$" >nul
    if not errorlevel 1 (
        if !dirname! gtr !ver! set ver=!dirname!
    )
)

if not "%target%"=="" (
    if exist "%~dp0spec\%target%\" (
        set ver=%target%
        set target=
    )
)

if not exist "%output_dir%" mkdir "%output_dir%"

if "%target%"=="" (
    del "%output_dir%\*.py" 2>nul
    if not "%ver%"=="common" (
        echo Using Version %ver%
        call "%~f0" common -o "%output_dir%"
    )
    echo Building %ver%
    for %%a in (%~dp0spec/%ver%/*.ksy) do (
        echo Compiling %%~nxa
        call ksc -t python "%~dp0spec/%ver%/%%~nxa" -d "%output_dir%" --python-package .
    )
) else (
    echo Compiling %target%
    call ksc -t python "%target%" -d "%output_dir%"
)