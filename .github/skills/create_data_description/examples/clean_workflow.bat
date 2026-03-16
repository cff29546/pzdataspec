@echo off
setlocal

set MODE=%1
if "%MODE%"=="" set MODE=build

powershell -ExecutionPolicy Bypass -File "%~dp0clean_workflow.ps1" -Mode "%MODE%"
exit /b %errorlevel%
