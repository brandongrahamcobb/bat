@echo off
setlocal enabledelayedexpansion

:: Function to prompt for input with a default value
:prompt_for_values
set "prompt_message=%1"
set "default_value=%2"
set /p "input_value=%prompt_message% [%default_value%]: "
if "!input_value!"=="" set "input_value=%default_value%"
exit /b 0

:: Function to update the config.json file
:update_config
setlocal
set "token=%~1"
set "user_agent=%~2"
set "mode=%~3"
set "version=%~4"
set "logging_level=%~5"
set "command_prefix=%~6"
set "database_url=%~7"
set "xp_rate=%~8"
set "publicity=%~9"

:: Construct the API keys JSON object
set "api_keys_json={"
for /l %%i in (1,1,20) do (
    set "api_key=!api_keys[%%i]!"
    if defined api_key (
        set "api_keys_json=!api_keys_json!\"api_key_%%i\": \"!api_key!\""
        if %%i lss 20 set "api_keys_json=!api_keys_json!, "
    )
)
set "api_keys_json=!api_keys_json!}"

if exist "%CONFIG_PATH%" (
    jq --arg token "%token%" ^
       --arg user_agent "%user_agent%" ^
       --arg mode "%mode%" ^
       --arg version "%version%" ^
       --arg logging_level "%logging_level%" ^
       --arg command_prefix "%command_prefix%" ^
       --arg database_url "%database_url%" ^
       --arg xp_rate "%xp_rate%" ^
       --arg publicity "%publicity%" ^
       --argjson api_keys "!api_keys_json!" ^
       ".token = \$token | .user_agent = \$user_agent | .mode = \$mode | .version = \$version | .logging_level = \$logging_level | .command_prefix = \$command_prefix | .database_url = \$database_url | .xp_rate = \$xp_rate | .publicity = \$publicity | .api_keys = \$api_keys" ^
       "%CONFIG_PATH%" > temp_config.json
    move /y temp_config.json "%CONFIG_PATH%" >nul
) else (
    mkdir "%~dpCONFIG_PATH%" 2>nul
    jq -n --arg token "%token%" ^
          --arg user_agent "%user_agent%" ^
          --arg mode "%mode%" ^
          --arg version "%version%" ^
          --arg logging_level "%logging_level%" ^
          --arg command_prefix "%command_prefix%" ^
          --arg database_url "%database_url%" ^
          --arg xp_rate "%xp_rate%" ^
          --arg publicity "%publicity%" ^
          --argjson api_keys "!api_keys_json!" ^
          "{token: \$token, user_agent: \$user_agent, mode: \$mode, version: \$version, logging_level: \$logging_level, command_prefix: \$command_prefix, database_url: \$database_url, xp_rate: \$xp_rate, publicity: \$publicity, api_keys: \$api_keys}" > "%CONFIG_PATH%"
)
endlocal
exit /b 0

:: Function to check for updates to the configuration file
:check_for_updates
setlocal
if exist "%CONFIG_PATH%" (
    for /l %%i in (1,1,20) do (
        set "current_api_key="
        for /f "delims=" %%k in ('jq -r ".api_keys.api_key_%%i" "%CONFIG_PATH%"') do set "current_api_key=%%k"
        call :prompt_for_values "Enter API key %%i" "!current_api_key!"
        set "api_keys[%%i]=!input_value!"
    )

    call :prompt_for_values "Enter the bot token" "$(jq -r '.token' "%CONFIG_PATH%")"
    set "TOKEN=!input_value!"
    call :prompt_for_values "Enter the User-Agent header" "$(jq -r '.user_agent' "%CONFIG_PATH%")"
    set "USER_AGENT=!input_value!"
    call :prompt_for_values "Enter the Mode" "$(jq -r '.mode' "%CONFIG_PATH%")"
    set "MODE=!input_value!"
    call :prompt_for_values "Enter the bot version" "$(jq -r '.version' "%CONFIG_PATH%")"
    set "VERSION=!input_value!"
    call :prompt_for_values "Enter the logging level" "$(jq -r '.logging_level' "%CONFIG_PATH%")"
    set "LOGGING_LEVEL=!input_value!"
    call :prompt_for_values "Enter the command prefix" "$(jq -r '.command_prefix' "%CONFIG_PATH%")"
    set "COMMAND_PREFIX=!input_value!"
    call :prompt_for_values "Enter the database URL" "$(jq -r '.database_url' "%CONFIG_PATH%")"
    set "DATABASE_URL=!input_value!"
    call :prompt_for_values "Enter the XP rate" "$(jq -r '.xp_rate' "%CONFIG_PATH%")"
    set "XP_RATE=!input_value!"
    call :prompt_for_values "Enter the publicity setting" "$(jq -r '.publicity' "%CONFIG_PATH%")"
    set "PUBLICITY=!input_value!"
) else (
    call :prompt_for_values "Enter the bot token" ""
    set "TOKEN=!input_value!"
    call :prompt_for_values "Enter the User-Agent header" "MyBot/1.0"
    set "USER_AGENT=!input_value!"
    call :prompt_for_values "Enter the Mode" "False"
    set "MODE=!input_value!"
    call :prompt_for_values "Enter the bot version" "0.0.0"
    set "VERSION=!input_value!"
    call :prompt_for_values "Enter the logging level" "INFO"
    set "LOGGING_LEVEL=!input_value!"
    call :prompt_for_values "Enter the command prefix" "!"
    set "COMMAND_PREFIX=!input_value!"
    call :prompt_for_values "Enter the database URL" ""
    set "DATABASE_URL=!input_value!"
    call :prompt_for_values "Enter the XP rate" "1"
    set "XP_RATE=!input_value!"
    call :prompt_for_values "Enter the publicity setting" "True"
    set "PUBLICITY=!input_value!"

    for /l %%i in (1,1,20) do (
        call :prompt_for_values "Enter API key %%i" ""
        set "api_keys[%%i]=!input_value!"
    )
)
endlocal
exit /b 0

:: Function to increment the version number in config.json
:increment_version
setlocal
for /f "tokens=1,2,3 delims=." %%a in ('jq -r ".version" "%CONFIG_PATH%"') do (
    set "major=%%a"
    set "minor=%%b"
    set "patch=%%c"
)
set /a patch+=1

if %patch% geq 10 (
    set "patch=0"
    set /a minor+=1
)
if %minor% geq 10 (
    set "minor=0"
    set /a major+=1
)
set "new_version=%major%.%minor%.%patch%"

:: Update the version in config.json
jq --arg version "%new_version%" ".version = \$version" "%CONFIG_PATH%" > temp_config.json
move /y temp_config.json "%CONFIG_PATH%" >nul
endlocal
exit /b 0

:: Main execution
set "CONFIG_PATH=C:\Users\%USERNAME%\AppData\Roaming\lucy\config.json"
set "api_keys="

:: Check for updates and update the config.json file
call :check_for_updates

:: Update the config.json file with the new values
call :update_config "%TOKEN%" "%USER_AGENT%" "%MODE%" "%VERSION%" "%LOGGING_LEVEL%" "%COMMAND_PREFIX%" "%DATABASE_URL%" "%XP_RATE%" "%PUBLICITY%"

:: Increment the version number
call :increment_version

:: Install required packages (assumes Python is installed and available in PATH)
pip install -r requirements.txt --upgrade

:: Run the bot
python C:\ProgramData\lucy\bot\main.py
