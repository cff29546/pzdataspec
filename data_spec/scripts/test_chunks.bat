@echo off
setlocal enabledelayedexpansion

set "save_folder=%~1"
set "output_folder=%~2"
if not defined output_folder set "output_folder=%~dp0..\..\output\chunk_parse"
if "%save_folder:~-1%"=="\" set "save_folder=%save_folder:~0,-1%"
if "%save_folder:~-1%"=="/" set "save_folder=%save_folder:~0,-1%"
if "%output_folder:~-1%"=="\" set "output_folder=%output_folder:~0,-1%"
if "%output_folder:~-1%"=="/" set "output_folder=%output_folder:~0,-1%"
if not exist "%output_folder%" mkdir "%output_folder%"

rem loop over all saved chunk files in the save folder
rem chunk files path pattern:
rem for old versions: %save_folder%\map_{x}_{y}.bin
rem for new versions: %save_folder%\map\{x}\{y}.bin

set chunk_found=0
rem skip old version for now
rem goto :new_version
rem check old version chunk files
:old_version
for %%x in ("%save_folder%\map_*_*.bin") do (
    set chunk_file=%%x
    for /f "tokens=2,3 delims=_." %%a in ("%%~nx") do (
        set chunk_x=%%a
        set chunk_y=%%b
    )
    rem echo Processing Chunk File: !chunk_file! [X: !chunk_x!, Y: !chunk_y!]
    set "output_file=%output_folder%\chunk_!chunk_x!_!chunk_y!.txt"
    python "%~dp0parse.py" chunk "!chunk_file!" -nv -o "!output_file!"
    if errorlevel 1 (
        echo Failed to parse chunk file: !chunk_file!
    )
    set /a chunk_found=!chunk_found!+1
)
:new_version

rem check new version chunk files
for /d %%x in ("%save_folder%\map\*") do (
    for %%y in ("%%x\*.bin") do (
        set chunk_file=%%y
        set chunk_x=%%~nx
        set chunk_y=%%~ny
        rem echo Processing Chunk File: !chunk_file! [X: !chunk_x!, Y: !chunk_y!]
        set "output_file=%output_folder%\chunk_!chunk_x!_!chunk_y!.txt"
        python "%~dp0parse.py" chunk "!chunk_file!" -nv -o "!output_file!"
        if errorlevel 1 (
            echo Failed to parse chunk file: !chunk_file!
        )
        set /a chunk_found=!chunk_found!+1
    )
)
echo Total chunk files processed: %chunk_found%
endlocal
