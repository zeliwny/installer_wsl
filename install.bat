@echo off
echo Checking if WSL is installed...

:: ---- Step 1: Check if WSL is Installed ----
powershell -ExecutionPolicy Bypass -Command "if (Get-Command wsl -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
if %errorlevel% neq 0 (
    echo WSL is not installed. Please install it manually.
    exit /b 1
)

echo Setting WSL 2 as default...
:: ---- Step 2: Set WSL 2 as Default ----
wsl --set-default-version 2
if %errorlevel% neq 0 (
    echo Failed to set WSL 2 as default. Make sure Virtual Machine Platform is enabled.
    exit /b 1
)

echo Importing the custom WSL distribution...
:: ---- Step 3: Import Custom Distro ----
wsl --import Cu-Ctool %USERPROFILE%\WSL\Cu-Ctool ctool.tar
if %errorlevel% neq 0 (
    echo Failed to import the custom WSL distribution.
    exit /b 1
)

echo Setting CustomDistro as the default...
:: ---- Step 4: Set Default Distro ----
wsl --set-default Cu-Ctool
if %errorlevel% neq 0 (
    echo Failed to set CustomDistro as the default.
    exit /b 1
)

echo Custom WSL installed successfully!
pause
exit /b 0
