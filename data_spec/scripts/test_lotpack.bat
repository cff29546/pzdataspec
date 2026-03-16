@echo off
setlocal enabledelayedexpansion

set "game_folder=%~1"
set "output_folder=%~2"
set "max_count=%~3"
if "%game_folder:~-1%"=="\" set "game_folder=%game_folder:~0,-1%"
if "%game_folder:~-1%"=="/" set "game_folder=%game_folder:~0,-1%"
if "%output_folder:~-1%"=="\" set "output_folder=%output_folder:~0,-1%"
if "%output_folder:~-1%"=="/" set "output_folder=%output_folder:~0,-1%"

rem loop over all *.lotpack files in the map folder
rem files path pattern:
rem for old versions: %game_folder%\media\maps\Muldraugh, KY\*.lotpack

set count=0

for %%x in ("%game_folder%\media\maps\Muldraugh, KY\*.lotpack") do (
    set lotpack=%%x
    set "output_file=%output_folder%\%%~nxx.txt"
    python "%~dp0parse.py" lotpack "!lotpack!" -nv -o "!output_file!"
    if errorlevel 1 (
        echo Failed to parse lotpack file: !lotpack!
    )
    set /a count=!count!+1
    if defined max_count if !count! GEQ !max_count! goto :end_loop
)
:end_loop
echo Total lotpack files processed: %count%
endlocal