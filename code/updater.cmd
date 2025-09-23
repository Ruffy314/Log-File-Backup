@echo off
setlocal

:: The template should be in the same folder as this updater
Set "_TEMPLATE=%~dp0script-template.cmd"

:: The directory with the scripts that need updating is one folder above
Set "_SCRIPT_DIR=%~dp0..\Einzelskripte"

echo Updating scripts in "%_SCRIPT_DIR%" with code from "%_TEMPLATE%"...
echo.

:: Create a temporary PowerShell script file
set "ps_temp=%TEMP%\update_scripts_temp.ps1"

:: Write PowerShell commands to temporary file
(
    echo $template = Get-Content -Raw '%_TEMPLATE%';
    echo $codeSection = $template -split ':::: ^<code^>' ^| Select-Object -Last 1;
    echo $scriptFiles = Get-ChildItem '%_SCRIPT_DIR%\*.cmd';
    echo foreach ($file in $scriptFiles^) {
    echo     Write-Host ('Processing: ' + $file.Name^);
    echo     $content = Get-Content -Raw $file.FullName;
    echo     if ($content -match ':::: ^<code^>'^) {
    echo         $configSection = $content -split ':::: ^<code^>' ^| Select-Object -First 1;
    echo         $newContent = $configSection + ':::: ^<code^>' + $codeSection;
    echo         Set-Content -Path $file.FullName -Value $newContent -NoNewline;
    echo         Write-Host ('- Updated ' + $file.Name + ' successfully'^);
    echo     } else {
    echo         Write-Host ('- Warning: Code section marker not found in ' + $file.Name^);
    echo     }
    echo     Write-Host '';
    echo }
    echo Write-Host 'All scripts have been updated.';
) > "%ps_temp%"

:: Execute the PowerShell script
powershell -ExecutionPolicy Bypass -File "%ps_temp%"

:: Clean up temporary file
del "%ps_temp%"

endlocal

pause