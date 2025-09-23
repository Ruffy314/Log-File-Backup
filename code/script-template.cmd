@echo off
setlocal enabledelayedexpansion

:::: ###################################################
:::: ####   Skript konfigurieren                    ####
:::: <conifg>

:: Quellverzeichnis und Zielverzeichnis
Set "_SOURCE=C:\Pfad\Zu\Daten\Ordner"
Set "_DESTINATION=C:\Pfad\Zum\Backup\Ordner"

:: Dateimuster für Filterung (z.B. nur bestimmte Dateiendungen *.txt)
Set "_MATCHING=*.log"

:::: </config>
:::: ###################################################
:::: <code>

:: timestamp file based on this script's name
Set "_TIMESTAMP_FILE=%~dpn0 - timestamp.txt"
:: Path to PowerShell script (one directory up from this batch file)
Set "_PS_SCRIPT=%~dp0..\code\file-copy.ps1"

:: Read or create timestamp of last run
if exist "%_TIMESTAMP_FILE%" (
    For /F "usebackq tokens=1* delims= " %%A In ("%_TIMESTAMP_FILE%") Do Set "_LAST_RUN=%%A %%B"
) else (
    :: If timestamp file doesn't exist, set default to 2 weeks ago
    echo Timestamp Datei nicht gefunden, nutze standardwert 14 Tage
    For /F "tokens=*" %%A In ('PowerShell -Command "Get-Date (Get-Date).AddDays(-14) -Format 'yyyy-MM-dd HH:mm'"') Do Set "_LAST_RUN=%%A"
)

:: Get current date and time for logging
For /F "tokens=*" %%A In ('PowerShell -Command "Get-Date -Format 'yyyy-MM-dd HH:mm'"') Do Set "_CURRENT_DATETIME=%%A"

:: Create destination directory if it doesn't exist
if not exist "%_DESTINATION%" mkdir "%_DESTINATION%"

:: Call the PowerShell script with the required parameters to copy the files
PowerShell -ExecutionPolicy ByPass -File "%_PS_SCRIPT%" "%_SOURCE%" "%_DESTINATION%" "%_MATCHING%" "%_LAST_RUN%"

:: Update timestamp file with current date and time to keep track of most recent execution
echo %_CURRENT_DATETIME%> "%_TIMESTAMP_FILE%"

endlocal

:: If called without args pause before exit 
:::: (the calling script will pass an argument to suppress this)
:::: But if the script is started with double click you can inspect output
IF "%1" EQU "" pause
:::: </code>