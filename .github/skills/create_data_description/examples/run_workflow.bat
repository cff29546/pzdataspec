@echo off
setlocal

set EXAMPLE=%1
if "%EXAMPLE%"=="" set EXAMPLE=all

powershell -ExecutionPolicy Bypass -File "%~dp0run_workflow.ps1" -Example "%EXAMPLE%"
exit /b %errorlevel%
