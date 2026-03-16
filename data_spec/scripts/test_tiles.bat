rem @echo off
setlocal enabledelayedexpansion

set "game_folder=%~1"
set "output_folder=%~2"
if "%game_folder:~-1%"=="\" set "game_folder=%game_folder:~0,-1%"
if "%game_folder:~-1%"=="/" set "game_folder=%game_folder:~0,-1%"
if "%output_folder:~-1%"=="\" set "output_folder=%output_folder:~0,-1%"
if "%output_folder:~-1%"=="/" set "output_folder=%output_folder:~0,-1%"

rem loop over all *.tiles files in the media folder
rem files path pattern:
rem for old versions: %game_folder%\media\*.tiles

for %%x in ("%game_folder%\media\*.tiles") do (
    set tiles=%%x
    set "output_file=%output_folder%\%%~nxx.txt"
    echo Processing Tiles File: !tiles!
    python "%~dp0parse.py" tile_def "!tiles!" -nv -o "!output_file!"
    if errorlevel 1 (
        echo Failed to parse tiles file: !tiles!
    )
)

endlocal
