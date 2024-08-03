@echo off
setlocal

set "base_dir=%~dp0"
set "py_dir=%base_dir%py"
set "downloads_dir=%USERPROFILE%\Downloads"
set "venv_dir=%downloads_dir%\venv"
set "config_path=%base_dir%json\config.json"

REM Function to set the bot token
call :set_token

REM Function to validate the bot token
call :validate_token

REM Function to set up the environment
call :setup_environment

REM Launch main.py
echo Launching bot...
%venv_dir%\Scripts\activate
python %py_dir%\main.py

exit /b

REM Function Definitions

:set_token
if not exist "%config_path%" (
    set /p "token=Enter your Discord bot token: "
    mkdir "%base_dir%json"
    echo {"token": "%token%"} > "%config_path%"
    echo Token has been saved to config.json.
) else (
    set /p "config=<%config_path%"
    echo %config% | findstr /r /c:"\"token\"" >nul
    if errorlevel 1 (
        set /p "token=Enter your Discord bot token: "
        echo %config% | sed "s/\"token\": \".*\"/\"token\": \"%token%\"/" > "%config_path%"
        echo Token has been updated in config.json.
    ) else (
        echo Token already set in config.json.
    )
)
exit /b

:validate_token
setlocal enabledelayedexpansion
:token_loop
for /f "delims=" %%i in ('type "%config_path%"') do set "config=%%i"
echo !config! | findstr /r /c:"\"token\"" >nul
if errorlevel 1 (
    echo Invalid token. Please enter a valid token.
    call :set_token
)
REM Placeholder for real validation, this is where you should implement actual validation logic
echo Token is valid.
exit /b

:setup_environment
REM Create Downloads directory if it doesn't exist
if not exist "%downloads_dir%" (
    mkdir "%downloads_dir%"
)

REM Create virtual environment
if not exist "%venv_dir%" (
    python -m venv "%venv_dir%"
)

REM Activate virtual environment and install requirements
%venv_dir%\Scripts\activate
pip install --upgrade pip
pip install discord.py emoji pubchempy rdkit pillow requests

REM Create necessary directories
mkdir "%base_dir%json"
mkdir "%base_dir%log"
mkdir "%base_dir%txt"
mkdir "%base_dir%md"
mkdir "%base_dir%plain"
mkdir "%base_dir%sh"
mkdir "%base_dir%bat"
mkdir "%py_dir%"

REM Move files to specific directories
if exist "%base_dir%README.md" move "%base_dir%README.md" "%base_dir%md\"
if exist "%base_dir%LICENSE" move "%base_dir%LICENSE" "%base_dir%plain\"
if exist "%base_dir%main.py" move "%base_dir%main.py" "%py_dir%\"
if exist "%base_dir%my_cog.py" move "%base_dir%my_cog.py" "%py_dir%\"
if exist "%base_dir%game_cog.py" move "%base_dir%game_cog.py" "%py_dir%\"
if exist "%base_dir%launch_bot.sh" move "%base_dir%launch_bot.sh" "%base_dir%sh\"

REM Move setup script to bat directory if not already there
if not exist "%base_dir%bat\setup.bat" (
    move "%base_dir%setup.bat" "%base_dir%bat\"
    echo Moved setup script to 'bat' directory.
    exit /b
)

exit /b
