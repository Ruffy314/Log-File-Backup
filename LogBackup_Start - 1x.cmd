@echo off

:: Autostart folder is %appdata%\Microsoft\Windows\Start Menu\Programs\Startup

:: In case a network drive is involved, wait until it is connected before proceding
:::: Windows may try to run an autostart before all drives are connected
SET LAUFWERK_1=G:

:check
IF EXIST %LAUFWERK_1%\NUL GOTO gefunden
ECHO !!! Laufwerk %LAUFWERK_1%\ [noch] nicht gefunden, warte auf Verbindung
TIMEOUT /T 5
GOTO check

:gefunden
:: Change to the directory containing the scripts
cd "./Einzelskripte"
	

:: Execute each .cmd script in the directory
for %%f in (*.cmd) do (
    call "%%f" --called
)

:: Wait 1 minute before closing this script
timeout /t 60

