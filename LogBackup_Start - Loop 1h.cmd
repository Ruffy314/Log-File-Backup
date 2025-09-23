@echo off

:: Change to the directory containing the scripts
cd "./Einzelskripte"
	
:loop

    :: Execute each .cmd script in the directory
    for %%f in (*.cmd) do (
        call "%%f" --called
    )

    :: Wait 60 minutes before running the scripts again
    timeout /t 3600

goto loop
