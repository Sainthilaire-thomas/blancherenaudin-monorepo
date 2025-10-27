Write-Host 'Analyzing all package imports in storefront...' -ForegroundColor Cyan

$patterns = @(
    '@blancherenaudin/ui',
    '@blancherenaudin/database',
    '@blancherenaudin/auth',
    '@blancherenaudin/sanity',
    '@blancherenaudin/utils',
    '@repo/ui',
    '@repo/database', 
    '@repo/supabase',
    '@repo/sanity',
    '@repo/utils',
    '@repo/types'
)

$results = @{}
foreach ($pattern in $patterns) {
    $results[$pattern] = @{ Count = 0; Files = @() }
}

$files = Get-ChildItem -Path 'apps/storefront' -Include '*.ts','*.tsx' -Recurse -File
Write-Host "Scanning $($files.Count) files..." -ForegroundColor Yellow

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    foreach ($pattern in $patterns) {
        if ($content -match [regex]::Escape($pattern)) {
            $results[$pattern].Count++
        }
    }
}

Write-Host "
RESULTS:" -ForegroundColor Cyan
foreach ($pattern in $patterns | Sort-Object) {
    if ($results[$pattern].Count -gt 0) {
        $color = if ($pattern -like '@blancherenaudin/*') { 'Red' } else { 'Green' }
        $status = if ($pattern -like '@blancherenaudin/*') { 'INCORRECT' } else { 'CORRECT' }
        Write-Host "$status $pattern : $($results[$pattern].Count) files" -ForegroundColor $color
    }
}

$incorrectCount = ($patterns | Where-Object { $_ -like '@blancherenaudin/*' -and $results[$_].Count -gt 0 }).Count
if ($incorrectCount -gt 0) {
    Write-Host "
CORRECTIONS NEEDED!" -ForegroundColor Yellow
} else {
    Write-Host "
All imports are correct!" -ForegroundColor Green
}
