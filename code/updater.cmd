@echo off
setlocal

:: The template should be in the same folder as this updater
Set "_TEMPLATE=%~dp0script-template.cmd"

:: The directory with the scripts that need updating is one folder above
Set "_SCRIPT_DIR=%~dp0..\Einzelskripte"

echo Updating scripts in %_SCRIPT_DIR% with code from %_TEMPLATE%...
echo.

:: Use PowerShell to handle the file operations
powershell -ExecutionPolicy Bypass -Command ^
    "$template = Get-Content -Raw '%_TEMPLATE%'; ^
    $codeSection = $template -split ':::: <code>' | Select-Object -Last 1; ^
    $scriptFiles = Get-ChildItem '%_SCRIPT_DIR%\*.cmd'; ^
    foreach ($file in $scriptFiles) { ^
        Write-Host ('Processing: ' + $file.Name); ^
        $content = Get-Content -Raw $file.FullName; ^
        if ($content -match ':::: <code>') { ^
            $configSection = $content -split ':::: <code>' | Select-Object -First 1; ^
            $newContent = $configSection + ':::: <code>' + $codeSection; ^
            Set-Content -Path $file.FullName -Value $newContent -NoNewline; ^
            Write-Host ('- Updated ' + $file.Name + ' successfully'); ^
        } else { ^
            Write-Host ('- Warning: Code section marker not found in ' + $file.Name); ^
        } ^
        Write-Host ''; ^
    } ^
    Write-Host 'All scripts have been updated.';"

endlocal