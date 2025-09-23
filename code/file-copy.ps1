#
# FileCopier.ps1
#
# This script copies files modified since a specified date and time from a source directory 
# to a destination directory, adding the modification date as a prefix to each filename.
# Compatible with German Windows systems.
#
# Parameters:
#   $args[0] - Source directory path
#   $args[1] - Destination directory path
#   $args[2] - File matching pattern (e.g., "*.txt")
#   $args[3] - Last run date and time in format 'yyyy-MM-dd HH:mm'
#

# Get command line arguments
$sourcePath = $args[0]
$destinationPath = $args[1]
$filePattern = $args[2]
$lastRunDateTime = $args[3]

# Display parameters for troubleshooting
Write-Host "Source: $sourcePath" 
Write-Host "Destination: $destinationPath"
Write-Host "Pattern: $filePattern"
Write-Host "Last run date/time: $lastRunDateTime"

# Convert the date/time string to a DateTime object for comparison
# Using InvariantCulture ensures consistent parsing regardless of system locale
try {
    $lastRun = [datetime]::ParseExact($lastRunDateTime, 'yyyy-MM-dd HH:mm', [System.Globalization.CultureInfo]::InvariantCulture)
    Write-Host "Parsed last run time: $($lastRun.ToString('yyyy-MM-dd HH:mm'))"
} catch {
    Write-Host "Error parsing timestamp '$lastRunDateTime'. Expected format: yyyy-MM-dd HH:mm"
    Write-Host "Error details: $($_.Exception.Message)"
    exit 1
}

# Verify source directory exists
if (-not (Test-Path $sourcePath)) {
    Write-Host "Error: Source directory '$sourcePath' does not exist."
    exit 1
}

# Get all files matching the pattern from the source directory
try {
    $files = Get-ChildItem -Path $sourcePath -Filter $filePattern -File -ErrorAction Stop
    Write-Host "Found $($files.Count) files matching pattern '$filePattern'"
} catch {
    Write-Host "Error accessing source directory: $($_.Exception.Message)"
    exit 1
}

# Initialize counter for statistics
$copiedFiles = 0

# Process each file
foreach ($file in $files) {
    # Check if the file was modified after the last run date/time
    if ($file.LastWriteTime -gt $lastRun) {
        # Create the date prefix based on the file's last modification date (using invariant culture)
        $datePrefix = $file.LastWriteTime.ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
        
        # Build the full destination path with date prefix
        $targetPath = Join-Path $destinationPath ($datePrefix + ' ' + $file.Name)
        
        try {
            # Copy the file to the destination
            Copy-Item -Path $file.FullName -Destination $targetPath -Force -ErrorAction Stop
            
            # Output information about the copied file with precise timestamp
            $fileTimeStamp = $file.LastWriteTime.ToString('yyyy-MM-dd HH:mm', [System.Globalization.CultureInfo]::InvariantCulture)
            Write-Host "Kopiert: $($file.Name) (geändert: $fileTimeStamp) -> $datePrefix $($file.Name)"
            
            # Increment counter
            $copiedFiles++
        } catch {
            Write-Host "Error copying file '$($file.FullName) to $targetPath': $($_.Exception.Message)"
        }
    } else {
        # Optional: Show skipped files for debugging
        $fileTimeStamp = $file.LastWriteTime.ToString('yyyy-MM-dd HH:mm', [System.Globalization.CultureInfo]::InvariantCulture)
        Write-Host "Übersprungen: $($file.Name) (geändert: $fileTimeStamp) - nicht neuer als $($lastRun.ToString('yyyy-MM-dd HH:mm'))"
    }
}

# Output summary
Write-Host "Abgeschlossen: $copiedFiles Dateien kopiert."