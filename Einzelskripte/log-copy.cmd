@echo off
setlocal enabledelayedexpansion

:: Quellverzeichnis und Zielverzeichnis
Set "_SOURCE=C:\Users\Public\Documents\test_public\data"
Set "_DESTINATION=C:\Users\Public\Documents\test_public\backup"

:: Skriptdatei und Zeitstempeldatei
Set "_TIMESTAMP_FILE=%~dpn0 - timestamp.txt"

@REM echo step 1

:: Read or create timestamp of last run
if exist "%_TIMESTAMP_FILE%" (
    For /F "usebackq tokens=1* delims= " %%A In ("%_TIMESTAMP_FILE%") Do Set "_LAST_RUN=%%A"
    echo Timestamp Datei gefunden Datum: "!_LAST_RUN!"
) else (
    :: If timestamp file doesn't exist, set default to 2 weeks ago
    echo Timestamp Datei nicht gefunden, nutze standardwert 14 Tage
    For /F "tokens=*" %%A In ('PowerShell -Command "Get-Date (Get-Date).AddDays(-14) -Format 'yyyy-MM-dd'"') Do Set "_LAST_RUN=%%A"
)

@REM echo step 2

:: Get current date for logging
For /F "tokens=*" %%A In ('PowerShell -Command "Get-Date -Format 'yyyy-MM-dd'"') Do Set "_CURRENT_DATE=%%A"

@REM echo step 3

echo Kopiere Dateien, die seit %_LAST_RUN% geaendert wurden, nach %_DESTINATION%

:: Create destination directory if it doesn't exist
if not exist "%_DESTINATION%" mkdir "%_DESTINATION%"

@REM echo step 4

:: Use a single-line PowerShell command with semicolons to separate statements
PowerShell -Command "$lastRun = [datetime]::ParseExact('%_LAST_RUN%', 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture); $files = Get-ChildItem -Path '%_SOURCE%' -File; foreach ($file in $files) { if ($file.LastWriteTime -gt $lastRun) { $datePrefix = $file.LastWriteTime.ToString('yyyy-MM-dd'); $targetPath = Join-Path '%_DESTINATION%' ($datePrefix + ' ' + $file.Name); Copy-Item -Path $file.FullName -Destination $targetPath -Force; Write-Host ('Kopiere: ' + $file.Name + ' -> ' + $datePrefix + ' ' + $file.Name); } }"

:: POWERSHELL COMMAND EXPLANATION:
:: 1. $lastRun = [datetime]::ParseExact('...')
::    - Converts the batch variable _LAST_RUN into a PowerShell DateTime object
::    - Uses the format 'yyyy-MM-dd' for parsing
::    - Ensures proper date comparisons regardless of locale settings
::
:: 2. $files = Get-ChildItem -Path '...' -File
::    - Gets a list of all files (not directories) from the source path
::    - Returns file objects with properties like LastWriteTime, Name, etc.
::
:: 3. foreach ($file in $files) { ... }
::    - Loops through each file found in the source directory
::
:: 4. if ($file.LastWriteTime -gt $lastRun) { ... }
::    - Checks if the file's last modification date is more recent than the last run date
::    - The -gt operator is "greater than" for proper date comparison
::
:: 5. $datePrefix = $file.LastWriteTime.ToString('yyyy-MM-dd')
::    - Gets the file's modification date in ISO format (YYYY-MM-DD)
::    - This will be used as prefix for the copied file
::
:: 6. $targetPath = Join-Path '...' ($datePrefix + ' ' + $file.Name)
::    - Creates the full path for the destination file
::    - Adds the date prefix to the original filename
::
:: 7. Copy-Item -Path $file.FullName -Destination $targetPath -Force
::    - Copies the file to the destination with the new name
::    - -Force flag overwrites existing files if necessary
::
:: 8. Write-Host ('Kopiere: ' + $file.Name + ' -> ' + $datePrefix + ' ' + $file.Name)
::    - Outputs a message showing which file is being copied and its new name


@REM echo step 5

:: Update timestamp file with current date to keep track of most recent execution
echo %_CURRENT_DATE% > "%_TIMESTAMP_FILE%"

@REM echo step 6

echo Backup abgeschlossen.
endlocal

:: If called without args pause before exit 
:::: (the calling script will pass an argument to suppress this)
:::: But if the script is started with double click you can inspect output
IF "%1" EQU "" pause