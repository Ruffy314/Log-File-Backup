@echo off

:: Change to the directory containing the scripts
cd "./Einzelskripte"
	
:loop

    :: Execute each .cmd script in the directory
    for %%f in (*.cmd) do (
        call "%%f" --called
    )

    :: Wait 24 hours before running the scripts again
    timeout /t 86400

goto loop
