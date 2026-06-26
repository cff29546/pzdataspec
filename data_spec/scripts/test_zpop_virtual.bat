@echo off
setlocal enabledelayedexpansion

set "save_folder=%~1"
set "output_folder=%~2"
if not defined save_folder set "save_folder=%~dp0..\..\output\saves\245\Apocalypse\2026-04-11_14-38-23"
if not defined output_folder set "output_folder=%~dp0..\..\output\tmp\zpop_virtual_parse"
if not exist "%output_folder%" mkdir "%output_folder%"

set "fail=0"
set "count=0"

if exist "%save_folder%\zpop\zpop_virtual.bin" (
    python "%~dp0parse.py" zpop "%save_folder%\zpop\zpop_virtual.bin" -p bool:1 -nv -o "%output_folder%\zpop_virtual.txt"
    if errorlevel 1 (
        echo Failed to parse: %save_folder%\zpop\zpop_virtual.bin
        set /a fail=!fail!+1
    )
    set /a count=!count!+1
)

if exist "%save_folder%\zpop_virtual.bin" (
    python "%~dp0parse.py" zpop "%save_folder%\zpop_virtual.bin" -p bool:1 -nv -o "%output_folder%\zpop_virtual.txt"
    if errorlevel 1 (
        echo Failed to parse: %save_folder%\zpop_virtual.bin
        set /a fail=!fail!+1
    )
    set /a count=!count!+1
)

echo Total zpop_virtual files processed: !count!  failures: !fail!
endlocal
