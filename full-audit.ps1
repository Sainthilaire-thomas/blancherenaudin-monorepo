Write-Host 'Checking ALL package.json files (including hidden)...' -ForegroundColor Cyan

$allFiles = Get-ChildItem -Path '.' -Filter 'package.json' -Recurse -Force | Where-Object { $_.DirectoryName -notmatch 'node_modules' }

Write-Host "Found $($allFiles.Count) files
" -ForegroundColor Yellow

$problemFiles = @()

foreach ($file in $allFiles) {
    $relativePath = $file.FullName.Replace((Get-Location).Path + '\', '')
    $size = (Get-Item $file.FullName).Length
    
    if ($size -eq 0) {
        Write-Host "X EMPTY: $relativePath (0 bytes)" -ForegroundColor Red
        $problemFiles += $relativePath
        continue
    }
    
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    
    if (-not $content -or [string]::IsNullOrWhiteSpace($content)) {
        Write-Host "X BLANK: $relativePath" -ForegroundColor Red
        $problemFiles += $relativePath
        continue
    }
    
    try {
        $null = $content | ConvertFrom-Json
        Write-Host "OK: $relativePath" -ForegroundColor Green
    } catch {
        Write-Host "X INVALID JSON: $relativePath" -ForegroundColor Red
        $problemFiles += $relativePath
    }
}

if ($problemFiles.Count -gt 0) {
    Write-Host "

PROBLEM FILES FOUND:" -ForegroundColor Red
    foreach ($file in $problemFiles) {
        Write-Host "  - $file" -ForegroundColor Yellow
    }
} else {
    Write-Host "

No problems found. Issue might be in Turbo cache." -ForegroundColor Yellow
    Write-Host "Try: npx @turbo/codemod@latest update" -ForegroundColor Cyan
}
