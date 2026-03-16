@echo off
setlocal enabledelayedexpansion

rem process parameters
for %%a in (%*) do (
    set %%a=1
)

rem load conf.txt variables
set temp_file=%temp%\conf_temp.txt
for /f "usebackq tokens=1,2 delims==" %%a in ("../conf.txt") do (
    set key=%%a
    set value=%%b
    cmd /c echo !value!>%temp_file%
    set /p !key!=<%temp_file%
)
del %temp_file%
echo PZ_ROOT=%PZ_ROOT%
echo PZ_SAVE_ROOT=%PZ_SAVE_ROOT%

set output_base=%~dp0..\output\parsed
if not exist %output_base%\map mkdir %output_base%\map
rem static files
VERIFY > nul
if "%t%"=="1" call %~dp0scripts\test_tiles.bat %PZ_ROOT% %output_base%
if "%lh%"=="1" call %~dp0scripts\test_lotheader.bat %PZ_ROOT% %output_base%\map 10
if "%lp%"=="1" call %~dp0scripts\test_lotpack.bat %PZ_ROOT% %output_base%\map 10

rem loop over each save
for /d %%g in ("%PZ_SAVE_ROOT%\*") do (
    for /d %%h in ("%%g\*") do (
        set save_path=%%h
        set save_name=%%~nh
        set output_folder=%output_base%\!save_name!
        
        echo Processing Save Folder: !save_name!
        echo Output Folder: !output_folder!
        if not exist "!output_folder!" mkdir "!output_folder!"

        rem chunk files
        if "%c%"=="1" call %~dp0scripts\test_chunks.bat "!save_path!" "!output_folder!"

        rem vehicles database
        if "%v%"=="1" call %~dp0scripts\test_vehicles.bat "!save_path!\vehicles.db" "!output_folder!\vehicles.txt"

        rem world dictionary
        VERIFY > nul
        if "%wd%"=="1" python %~dp0scripts\parse.py world_dictionary "!save_path!\WorldDictionary.bin" -nv -o "!output_folder!\world_dictionary.txt" 2>nul
        if errorlevel 1 echo Error parsing WorldDictionary for save !save_name!

        rem metadata
        VERIFY > nul
        if "%m%"=="1" python %~dp0scripts\parse.py metadata "!save_path!\metadata.bin" -o "!output_folder!\metadata.txt" 2>nul
        if errorlevel 1 echo Error parsing metadata for save !save_name!

        rem visited
        VERIFY > nul
        if "%vis%"=="1" python %~dp0scripts\parse.py visited "!save_path!\map_visited.bin" -o "!output_folder!\visited.txt" 2>nul
        if errorlevel 1 echo Error parsing visited for save !save_name!
    )
)