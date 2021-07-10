@echo off
setlocal

pushd %~dp0
set SCRIPT_DIR=%CD%
popd

for %%A in ("%SCRIPT_DIR%") do for %%B in ("%%~dpA.") do set BASH_SCRIPTS_DIR=%%~dpB%%~nxB
for %%A in ("%BASH_SCRIPTS_DIR%") do for %%B in ("%%~dpA.") do set WORKSPACE_DIR=%%~dpB%%~nxB

cd /d %WORKSPACE_DIR%

set HOSTS_PATH="%SystemDrive%\Windows\System32\drivers\etc\hosts"
set HOSTS_LINK="%WORKSPACE_DIR%\hosts.link"

mklink %HOSTS_LINK% %HOSTS_PATH% > nul 2>&1 ^
    && echo "The link %HOSTS_LINK% to hosts file has been created" ^
    || echo "The link %HOSTS_LINK% to hosts file creation error"