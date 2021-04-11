@echo off
setlocal

set DOMAIN=%1

if not defined DOMAIN (
    echo Usage: %~nx0 ^<domain^>
    exit /b 0
)

pushd %~dp0
set SCRIPT_DIR=%CD%
popd

for %%A in ("%SCRIPT_DIR%") do for %%B in ("%%~dpA.") do set BASH_SCRIPTS_DIR=%%~dpB%%~nxB
for %%A in ("%BASH_SCRIPTS_DIR%") do for %%B in ("%%~dpA.") do set WORKSPACE_DIR=%%~dpB%%~nxB

set CERTS_DIR=%WORKSPACE_DIR%\data\certs\hosts

set CERT_PEM=%DOMAIN%-cert.pem
set CERT_KEY=%DOMAIN%-cert.key

cd /d %CERTS_DIR%

mkcert -cert-file "%CERT_PEM%" -key-file "%CERT_KEY%" "%DOMAIN%" "*.%DOMAIN%" > nul 2>&1 ^
    && echo "SSL certificate is generated (%CERT_PEM% and %CERT_KEY%) and put to the directory %CERTS_DIR%" ^
    || echo "Error when generating SSL certificate"