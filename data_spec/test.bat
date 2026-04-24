@echo off
setlocal enabledelayedexpansion

set "save_path=%~1"
if "%save_path:~-1%"=="\" set "save_path=%save_path:~0,-1%"
if "%save_path:~-1%"=="/" set "save_path=%save_path:~0,-1%"
for %%I in ("%save_path%") do set "save_name=%%~nI"
shift /1
rem process parameters
for %%a in (%*) do (
    set %%a=1
)

rem load conf.txt variables
set temp_file=%temp%\conf_temp.txt
for /f "usebackq tokens=1,2 delims==" %%a in ("%~dp0..\conf.txt") do (
    set key=%%a
    set value=%%b
    cmd /c echo !value!>%temp_file%
    set /p !key!=<%temp_file%
)
del %temp_file%

set "output_base=%~dp0..\output\parsed"
set "output_log=%output_base%\TEST_LOG.txt"
set "output_log_error=%output_base%\TEST_LOG_ERROR.txt"
set "output_log_state=%output_base%\TEST_LOG_STATE.txt"
set "output_tmp=%output_base%\TEST_TMP.txt"
set "output_folder=%output_base%\%save_name%"
echo Working... > "%output_log_state%"
echo Processing Save Folder: %save_name%
echo Check "%output_log_state%" for job status.
echo Processing Save Folder: %save_name% > "%output_log%"
echo Output Folder: %output_folder% >> "%output_log%"
echo Error logging for %save_name% > "%output_log_error%"
if not exist "%output_folder%" mkdir "%output_folder%"

rem chunk files
if "%c%"=="1" (
    call %~dp0scripts\test_chunks.bat "%save_path%" "%output_folder%" > "%output_tmp%" 2>> "%output_log_error%"
    type "%output_tmp%"
    type "%output_tmp%" >> "%output_log%"
)

rem vehicles database
if "%v%"=="1" (
    call %~dp0scripts\test_vehicles.bat "%save_path%\vehicles.db" "%output_folder%\vehicles.txt" > "%output_tmp%" 2>> "%output_log_error%"
    type "%output_tmp%"
    type "%output_tmp%" >> "%output_log%"
)

rem players database
if "%p%"=="1" (
    call %~dp0scripts\test_players.bat "%save_path%\players.db" "%output_folder%\players.txt" > "%output_tmp%" 2>> "%output_log_error%"
    type "%output_tmp%"
    type "%output_tmp%" >> "%output_log%"
)

rem world dictionary
if "%wd%"=="1" (
    VERIFY > nul
    python %~dp0scripts\parse.py world_dictionary "%save_path%\WorldDictionary.bin" -nv -o "%output_folder%\world_dictionary.txt" 2>> "%output_log_error%"
    if errorlevel 1 (
        echo Error parsing WorldDictionary for save %save_name%
        echo Error parsing WorldDictionary for save %save_name% >> "%output_log%"
    ) else (
        echo Parsing WorldDictionary with no errors for save %save_name%
        echo Parsing WorldDictionary with no errors for save %save_name% >> "%output_log%"
    )
)

rem metadata
rem metadata doesn't exist in older saves, so we check for existence before trying to parse
if not exist "%save_path%\metadata.bin" goto :visited
VERIFY > nul
if "%m%"=="1" (
    python %~dp0scripts\parse.py metadata "%save_path%\metadata.bin" -o "%output_folder%\metadata.txt" 2>> "%output_log_error%"
    if errorlevel 1 (
        echo Error parsing metadata for save %save_name%
        echo Error parsing metadata for save %save_name% >> "%output_log%"
    ) else (
        echo Parsing metadata with no errors for save %save_name%
        echo Parsing metadata with no errors for save %save_name% >> "%output_log%"
    )
)

:visited
rem visited
VERIFY > nul
if "%vis%"=="1" (
    python %~dp0scripts\parse.py visited "%save_path%\map_visited.bin" -o "%output_folder%\visited.txt" 2>> "%output_log_error%"
    if errorlevel 1 (
        echo Error parsing visited for save %save_name%
        echo Error parsing visited for save %save_name% >> "%output_log%"
    ) else (
        echo Parsing visited with no errors for save %save_name%
        echo Parsing visited with no errors for save %save_name% >> "%output_log%"
    )
)

del "%output_tmp%" 2>nul
echo Done. >> "%output_log_state%"