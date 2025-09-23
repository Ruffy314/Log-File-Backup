# Diagnostic script to identify path issues
# Run this to debug the path problem with foo3.txt

$sourcePath = "C:\Users\Public\Documents\test_public\data"
$destinationPath = "C:\Users\Public\Documents\test_public\backup"
$fileName = "foo3.txt"

Write-Host "=== PATH DIAGNOSTIC ==="
Write-Host "Source directory: '$sourcePath'"
Write-Host "Destination directory: '$destinationPath'"
Write-Host "Target filename: '$fileName'"
Write-Host ""

# Check if source directory exists
Write-Host "Source directory exists: $(Test-Path $sourcePath)"

# Check if destination directory exists
Write-Host "Destination directory exists: $(Test-Path $destinationPath)"

# Check if the specific file exists
$fullSourcePath = Join-Path $sourcePath $fileName
Write-Host "Source file exists: $(Test-Path $fullSourcePath)"

if (Test-Path $fullSourcePath) {
    $file = Get-Item $fullSourcePath
    Write-Host "File details:"
    Write-Host "  Full path: '$($file.FullName)'"
    Write-Host "  Name: '$($file.Name)'"
    Write-Host "  LastWriteTime: $($file.LastWriteTime)"
    Write-Host "  Length: $($file.Length) bytes"
    
    # Test path construction
    $datePrefix = $file.LastWriteTime.ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
    $destinationFileName = $datePrefix + ' ' + $file.Name
    $targetPath = Join-Path $destinationPath $destinationFileName
    
    Write-Host ""
    Write-Host "Target path construction:"
    Write-Host "  Date prefix: '$datePrefix'"
    Write-Host "  Destination filename: '$destinationFileName'"
    Write-Host "  Full target path: '$targetPath'"
    
    # Check for invalid characters
    $invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
    $invalidPathChars = [System.IO.Path]::GetInvalidPathChars()
    
    Write-Host ""
    Write-Host "Character validation:"
    $hasInvalidFileNameChars = $false
    $hasInvalidPathChars = $false
    
    foreach ($char in $invalidChars) {
        if ($destinationFileName.Contains($char)) {
            Write-Host "  Invalid filename character found: '$char' (ASCII: $([int][char]$char))"
            $hasInvalidFileNameChars = $true
        }
    }
    
    foreach ($char in $invalidPathChars) {
        if ($targetPath.Contains($char)) {
            Write-Host "  Invalid path character found: '$char' (ASCII: $([int][char]$char))"
            $hasInvalidPathChars = $true
        }
    }
    
    if (-not $hasInvalidFileNameChars -and -not $hasInvalidPathChars) {
        Write-Host "  No invalid characters found"
    }
    
    # Try to create destination directory
    Write-Host ""
    Write-Host "Creating destination directory..."
    try {
        if (-not (Test-Path $destinationPath)) {
            New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
            Write-Host "  Destination directory created successfully"
        } else {
            Write-Host "  Destination directory already exists"
        }
    } catch {
        Write-Host "  Error creating destination directory: $($_.Exception.Message)"
    }
    
    # Test actual copy operation
    Write-Host ""
    Write-Host "Testing copy operation..."
    try {
        Copy-Item -Path $file.FullName -Destination $targetPath -Force -ErrorAction Stop
        Write-Host "  Copy successful!"
        
        # Verify the copied file
        if (Test-Path $targetPath) {
            $copiedFile = Get-Item $targetPath
            Write-Host "  Copied file size: $($copiedFile.Length) bytes"
        }
    } catch {
        Write-Host "  Copy failed: $($_.Exception.Message)"
        Write-Host "  Exception type: $($_.Exception.GetType().FullName)"
        Write-Host "  Full exception: $($_.Exception.ToString())"
    }
} else {
    Write-Host "File '$fileName' not found in source directory"
    
    # List all files in source directory
    Write-Host ""
    Write-Host "Files in source directory:"
    if (Test-Path $sourcePath) {
        Get-ChildItem -Path $sourcePath -File | ForEach-Object {
            Write-Host "  '$($_.Name)'"
        }
    }
}

Write-Host ""
Write-Host "=== END DIAGNOSTIC ==="