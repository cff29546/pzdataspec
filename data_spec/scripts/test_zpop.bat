@echo off
setlocal enabledelayedexpansion

set "save_folder=%~1"
set "output_folder=%~2"
if not defined save_folder set "save_folder=%~dp0..\..\output\saves\245\Apocalypse\2026-04-11_14-38-23"
if not defined output_folder set "output_folder=%~dp0..\..\output\tmp\zpop_parse"
if not exist "%output_folder%" mkdir "%output_folder%"

set count=0
set fail=0
for %%f in ("%save_folder%\zpop\zpop_*.bin") do (
    if /i not "%%~nxf"=="zpop_virtual.bin" (
        python "%~dp0parse.py" zpop "%%f" -p bool:0 -nv -o "%output_folder%\%%~nf.txt"
        if errorlevel 1 (
            echo Failed to parse: %%f
            set /a fail=!fail!+1
        )
        set /a count=!count!+1
    )
)
for %%f in ("%save_folder%\zpop_*.bin") do (
    if /i not "%%~nxf"=="zpop_virtual.bin" (
        python "%~dp0parse.py" zpop "%%f" -p bool:0 -nv -o "%output_folder%\%%~nf.txt"
        if errorlevel 1 (
            echo Failed to parse: %%f
            set /a fail=!fail!+1
        )
        set /a count=!count!+1
    )
)
echo Total zpop files processed: !count!  failures: !fail!
endlocal
