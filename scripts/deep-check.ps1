Write-Host 'Deep check for all package.json files...' -ForegroundColor Cyan

$allFiles = Get-ChildItem -Path '.' -Filter 'package.json' -Recurse | Where-Object { $_.DirectoryName -notmatch 'node_modules' }

Write-Host "Found $($allFiles.Count) package.json files
" -ForegroundColor Yellow

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace((Get-Location).Path + '\', '')
    Write-Host "
File: $relativePath" -ForegroundColor Cyan
    
    $size = (Get-Item $file.FullName).Length
    Write-Host "  Size: $size bytes" -ForegroundColor Gray
    
    if ($size -eq 0) {
        Write-Host '  X EMPTY FILE (0 bytes)!' -ForegroundColor Red
        continue
    }
    
    $content = Get-Content $file.FullName -Raw
    
    if ([string]::IsNullOrWhiteSpace($content)) {
        Write-Host '  X FILE IS BLANK/WHITESPACE ONLY!' -ForegroundColor Red
        continue
    }
    
    if ($content.Length -lt 10) {
        Write-Host "  X TOO SHORT ($($content.Length) chars)" -ForegroundColor Red
        Write-Host "  Content: $content" -ForegroundColor Yellow
        continue
    }
    
    try {
        $json = $content | ConvertFrom-Json
        Write-Host '  OK Valid JSON' -ForegroundColor Green
    } catch {
        Write-Host '  X INVALID JSON!' -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "
  First 300 chars:" -ForegroundColor Yellow
        Write-Host $content.Substring(0, [Math]::Min(300, $content.Length)) -ForegroundColor Gray
    }
}
