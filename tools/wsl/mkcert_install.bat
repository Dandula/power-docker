@echo off

echo This will first install package manager Chocolatey, then mkcert
echo.

pause
echo.
net session > nul 2>&1
if %ERRORLEVEL% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    exit /b 1
)
echo.

echo.
powershell -NoProfile -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && set PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin
choco feature enable -n=allowGlobalConfirmation

pause
echo.
choco install mkcert

pause
echo.
mkcert -install