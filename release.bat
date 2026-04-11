@echo off
setlocal enabledelayedexpansion
rem build release artifacts
rem usage: release.bat [target]

rem target can be a version number, "latest", or "clean". If not specified, all versions will be built.

set target=%1
set output_dir=%~dp0output\release\pzdataspec

if "%target%"=="clean" (
    rd /s /q "%output_dir%"
    exit /b
)
rem clear output directory
if exist "%output_dir%" rd /s /q "%output_dir%"
rem copy pzdataspec to output directory
xcopy "%~dp0pzdataspec" "%output_dir%" /y /e /i
rem build all versions
for /d %%a in (%~dp0data_spec\spec\*) do (
    set dirname=%%~nxa
    rem check if the directory name is a number
    echo(!dirname!| findstr /r "^[0-9][0-9]*$" >nul
    if not errorlevel 1 (
        call :build_single !dirname!
    )
)
python "%~dp0scripts\gen_release_notes.py" all

rem pack output/release/pzdataspec.zip
pushd "%~dp0output\release"
if exist pzdataspec.zip del pzdataspec.zip
rem powershell.exe -NoProfile -Command "$archive = Join-Path $PSHOME 'Modules\Microsoft.PowerShell.Archive\Microsoft.PowerShell.Archive.psd1'; Import-Module $archive -ErrorAction Stop; Compress-Archive -Path 'pzdataspec' -DestinationPath 'pzdataspec.zip'"
where pwsh >nul 2>&1
if ERRORLEVEL 1 (
    powershell -Command "Compress-Archive -Path pzdataspec -DestinationPath pzdataspec.zip"
) else (
    pwsh -Command "Compress-Archive -Path pzdataspec -DestinationPath pzdataspec.zip"
)
popd
goto :eof

:build_single
rem build spec
call "%~dp0data_spec\build.bat" %1 -o "%output_dir%\spec\v%1"
exit /b

:eof