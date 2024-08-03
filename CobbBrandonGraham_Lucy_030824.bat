@echo off
setlocal

set "base_dir=%~dp0"
set "bot_dir=%base_dir%bot"
set "venv_dir=%USERPROFILE%\Downloads\venv"
set "requirements_file=%base_dir%requirements.txt"
set "config_path=%base_dir%\config.json"

:: Function to set the bot token
call :set_token

:: Check if the script is already in the right directory
if "%~nx0" == "setup.bat" (
    echo Setup script is inside 'bat' directory. Doing nothing.
    exit /b 0
)

:: Set up the virtual environment
echo Setting up virtual environment in Downloads directory...
if not exist "%venv_dir%" (
    python -m venv "%venv_dir%"
)
call "%venv_dir%\Scripts\activate.bat"
pip install --upgrade pip
pip install -r "%requirements_file%"

:: Launch the bot
echo Launching bot...
python "%bot_dir%\main.py"

goto :eof

:set_token
if not exist "%config_path%" (
    set /p "token=Enter your Discord bot token: "
    mkdir "%config_dir%" 2>nul
    echo {"token": "%token%"} > "%config_path%"
    echo Token has been saved to config.json.
) else (
    findstr /c:"\"token\"" "%config_path%" >nul || (
        set /p "token=Enter your Discord bot token: "
        powershell -Command "(Get-Content -Path '%config_path%') -replace '\"token\": \".*\"', '\"token\": \"%token%\"' | Set-Content -Path '%config_path%'"
        echo Token has been updated in config.json.
    )
)
goto :eof
