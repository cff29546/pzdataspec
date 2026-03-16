@echo off
setlocal enabledelayedexpansion

set "game_folder=%~1"
set "output_folder=%~2"
set "max_count=%~3"
if "%game_folder:~-1%"=="\" set "game_folder=%game_folder:~0,-1%"
if "%game_folder:~-1%"=="/" set "game_folder=%game_folder:~0,-1%"
if "%output_folder:~-1%"=="\" set "output_folder=%output_folder:~0,-1%"
if "%output_folder:~-1%"=="/" set "output_folder=%output_folder:~0,-1%"

rem loop over all *.lotheader files in the map folder
rem files path pattern:
rem for old versions: %game_folder%\media\maps\Muldraugh, KY\*.lotheader

set count=0

for %%x in ("%game_folder%\media\maps\Muldraugh, KY\*.lotheader") do (
    set lotheader=%%x
    set "output_file=%output_folder%\%%~nxx.txt"
    python "%~dp0parse.py" lotheader "!lotheader!" -nv -o "!output_file!"
    if errorlevel 1 (
        echo Failed to parse lotheader file: !lotheader!
    )
    set /a count=!count!+1
    if defined max_count if !count! GEQ !max_count! goto :end_loop
)
:end_loop
echo Total lotheader files processed: %count%
endlocal