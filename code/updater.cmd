@echo off

:: The template should be in the same folder as this updater
Set "_TEMPLATE=%~dp0script-template.cmd"

:: The directory with the scripts that need updating is one folder above
Set "_SCRIPT_DIR=%~dp0..\Einzelskripte"

:: ---

:: This update-script updates the code parts of the actually executed scripts
:: according to the template, while leaving the configuration parts unchanged.

:: TODO