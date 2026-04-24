@echo off
setlocal enabledelayedexpansion

set "db_file=%~1"
set "output_file=%~2"
if "%db_file:~-1%"=="\" set "db_file=%db_file:~0,-1%"
if "%db_file:~-1%"=="/" set "db_file=%db_file:~0,-1%"
if "%output_file:~-1%"=="\" set "output_file=%output_file:~0,-1%"
if "%output_file:~-1%"=="/" set "output_file=%output_file:~0,-1%"
for %%I in ("%output_file%") do set "output_dir=%%~dpI"
if "!output_dir:~-1!"=="\" set "output_dir=!output_dir:~0,-1!"

echo Testing Players DB (localPlayers): %db_file%
python "%~dp0parse_db.py" iso_object "%db_file%" localPlayers -d data -a worldversion -e 0 -o "%output_file%" -D "!output_dir!"
endlocal
