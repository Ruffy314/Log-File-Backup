#
# FileCopier.ps1
#
# This script copies files modified since a specified date from a source directory 
# to a destination directory, adding the modification date as a prefix to each filename.
#
# Parameters:
#   $args[0] - Source directory path
#   $args[1] - Destination directory path
#   $args[2] - File matching pattern (e.g., "*.txt")
#   $args[3] - Last run date in format 'yyyy-MM-dd'
#

# Get command line arguments
$sourcePath = $args[0]
$destinationPath = $args[1]
$filePattern = $args[2]
$lastRunDate = $args[3]

# Display parameters for troubleshooting
Write-Host "Source: $sourcePath" 
Write-Host "Destination: $destinationPath"
Write-Host "Pattern: $filePattern"
Write-Host "Last run date: $lastRunDate"

# Convert the date string to a DateTime object for comparison
$lastRun = [datetime]::ParseExact($lastRunDate, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)

# Get all files matching the pattern from the source directory
$files = Get-ChildItem -Path $sourcePath -Filter $filePattern -File

# Initialize counter for statistics
$copiedFiles = 0

# Process each file
foreach ($file in $files) {
  # Check if the file was modified after the last run date
  if ($file.LastWriteTime -gt $lastRun) {
    # Create the date prefix based on the file's last modification date
    $datePrefix = $file.LastWriteTime.ToString('yyyy-MM-dd')
    
    # Build the full destination path with date prefix
    $targetPath = Join-Path $destinationPath ($datePrefix + ' ' + $file.Name)
    
    # Copy the file to the destination
    Copy-Item -Path $file.FullName -Destination $targetPath -Force
    
    # Output information about the copied file
    Write-Host "Kopiere: $($file.Name) -> $datePrefix $($file.Name)"
    
    # Increment counter
    $copiedFiles++
  }
}

# Output summary
Write-Host "Abgeschlossen: $copiedFiles Dateien kopiert."