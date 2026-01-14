# Cleanup script for temporary Claude files
# Run this periodically to move temp files to the temp folder

Write-Host "Cleaning up temporary Claude files..."

# Ensure temp directory exists
if (!(Test-Path "temp")) {
    New-Item -ItemType Directory -Path "temp" | Out-Null
}

# Move any tmpclaude-*-cwd files to temp folder
Get-ChildItem -Path . -Filter "tmpclaude-*-cwd" -File | ForEach-Object {
    Move-Item -Path $_.FullName -Destination "temp\" -Force
    Write-Host "Moved $($_.Name) to temp/"
}

Write-Host "Cleanup complete!"
