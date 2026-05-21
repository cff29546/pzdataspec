@echo off
setlocal enabledelayedexpansion
rem arg1: either a version number or a path to a .ksy file
rem optional: -o output_dir to set output directory for generated python files
rem compatibility: arg2 is still treated as output_dir when -o is not used
rem if arg1 is omitted, the latest version is used
set target=%~1
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

set ksc=kaitai-struct-compiler
where %ksc% >nul 2>&1
if errorlevel 1 (
    set ksc=ksc
    where !ksc! >nul 2>&1
    if errorlevel 1 (
        echo Error: kaitai-struct-compiler not found in PATH
        exit /b 1
    )
)

if not exist "%output_dir%" mkdir "%output_dir%"

if "%target%"=="" (
    call :clean_output
    if not "%ver%"=="common" (
        echo Using Version %ver%
        call :process_dir "%~dp0spec\common"
    )
    echo Building %ver%
    call :process_dir "%~dp0spec\%ver%"
) else (
    if "%target%"=="clean" (
        call :clean_output
        exit /b 0
    )
    if exist "%target%\" (
        echo Building %target%
        call :process_dir "%target%"
    ) else (
        call :process_file "%target%"
    )
)

exit /b 0

:clean_output
del "%output_dir%\*.py" 2>nul
exit /b

:process_file
echo Compiling %~nx1
call %ksc% -t python "%~f1" -d "%output_dir%" --python-package .
if errorlevel 1 (
    echo Error compiling %~nx1
)
exit /b

:process_dir
for %%a in ("%~f1\*.ksy") do (
    call :process_file "%%~fa"
)
for %%a in ("%~f1\*.py") do (
    echo Copying %%~nxa
    copy /Y "%%~fa" "%output_dir%\..\%%~nxa" >nul
)
exit /b
