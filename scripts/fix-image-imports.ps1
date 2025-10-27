Write-Host 'Fixing @/lib/images imports to @repo/utils...' -ForegroundColor Cyan

$files = Get-ChildItem -Path 'apps/storefront' -Include '*.ts','*.tsx' -Recurse -File

$count = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    if ($content -match 'from [''"]@/lib/images[''"]') {
        Write-Host "Fixing: $($file.FullName.Replace((Get-Location).Path + '\', ''))" -ForegroundColor Yellow
        
        $newContent = $content -replace 'from [''"]@/lib/images[''"]', 'from ''@repo/utils'''
        
        [System.IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.Encoding]::UTF8)
        
        $count++
    }
}

Write-Host "
Fixed $count files!" -ForegroundColor Green
