@echo off

setlocal enabledelayedexpansion

set tool_base=%~dp0..\output\tools
set output_base=%~dp0..\output\decompiled

if not exist %tool_base% (
    mkdir %tool_base%
)

if not exist %output_base% (
    mkdir %output_base%
)

:: download decompilation tools if not present
if not exist %tool_base%\vineflower.jar (
    set LATEST_VINEFLOWER_URL=https://github.com/Vineflower/vineflower/releases/download/1.11.2/vineflower-1.11.2.jar
    :: dynamically get latest vineflower release
    for /f "tokens=*" %%i in ('curl -s https://api.github.com/repos/Vineflower/vineflower/releases/latest ^| findstr /r /c:"browser_download_url.*vineflower-.*\.jar" ^| findstr /v "slim"') do (
        for /f "tokens=1,* delims=:" %%j in ("%%i") do (
            echo Latest Vineflower URL: %%~k
            set LATEST_VINEFLOWER_URL=%%~k
        )
    )

    echo Downloading Vineflower decompiler...
    curl -L -o %tool_base%\vineflower.jar !LATEST_VINEFLOWER_URL!
)


:: load conf.txt variables
set temp_file=%temp%\conf_temp.txt
for /f "usebackq tokens=1,2 delims==" %%a in ("%~dp0..\conf.txt") do (
    cmd /c echo %%b>%temp_file%
    set /p %%a=<%temp_file%
)

:: decompile game jar
if exist %output_base%\current_version (
    echo a decompiled version already exists, please remove it before proceeding
    echo path: %output_base%\current_version
    echo Decompilation terminated.
    exit /b
)

echo Decompiling Project Zomboid jar...
if exist %PZ_ROOT%\projectzomboid.jar (
    :: new version, single jar file
    java -jar %tool_base%\vineflower.jar %PZ_ROOT%\projectzomboid.jar %output_base%\current_version
) else (
    :: old version, jar files and folders
    java -jar %tool_base%\vineflower.jar %PZ_ROOT%\*.jar %output_base%\current_version
    for /d %%d in (%PZ_ROOT%\*) do (
        set dirname=%%~nxd
        :: skip binary and assets folders
        if "!dirname!"=="jre" set dirname=
        if "!dirname!"=="jre64" set dirname=
        if "!dirname!"=="launcher" set dirname=
        if "!dirname!"=="license" set dirname=
        if "!dirname!"=="media" set dirname=
        if "!dirname!"=="mods" set dirname=
        if "!dirname!"=="win32" set dirname=
        if "!dirname!"=="win64" set dirname=
        if "!dirname!"=="Workshop" set dirname=
        if not "!dirname!"=="" (
            java -jar %tool_base%\vineflower.jar %%d %output_base%\current_version\!dirname!
        )
    )
)

:: extract world version and move to versioned folder
python %~dp0get_decompiled_version.py update %output_base% %~dp0..\data_spec\spec\version_mapping.yaml