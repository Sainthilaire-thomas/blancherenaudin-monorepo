Write-Host 'Checking all package.json files...' -ForegroundColor Cyan

$packageJsons = Get-ChildItem -Path '.' -Include 'package.json' -Recurse -Depth 3 | Where-Object { $_.DirectoryName -notmatch 'node_modules' }

Write-Host "Found $($packageJsons.Count) package.json files
" -ForegroundColor Yellow

foreach ($file in $packageJsons) {
    Write-Host "Checking: $($file.FullName)" -ForegroundColor Cyan
    try {
        $content = Get-Content $file.FullName -Raw
        if ([string]::IsNullOrWhiteSpace($content)) {
            Write-Host '  X EMPTY FILE!' -ForegroundColor Red
            continue
        }
        $json = $content | ConvertFrom-Json
        Write-Host '  OK Valid JSON' -ForegroundColor Green
    } catch {
        Write-Host '  X INVALID JSON!' -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "
First 500 characters:" -ForegroundColor Yellow
        $preview = $content.Substring(0, [Math]::Min(500, $content.Length))
        Write-Host $preview -ForegroundColor Gray
        Write-Host "
---
" -ForegroundColor Yellow
    }
}
