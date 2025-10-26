Write-Host 'Correcting @/ imports to @repo/* packages...' -ForegroundColor Cyan

$files = Get-ChildItem -Path 'apps/storefront' -Include '*.ts','*.tsx' -Recurse -File
$totalFixed = 0
$filesModified = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileFixed = 0
    
    # 1. Database (Supabase)
    $content = $content -replace 'from [''"]@/lib/supabase-server[''"]', 'from ''@repo/database'''
    $content = $content -replace 'from [''"]@/lib/supabase-browser[''"]', 'from ''@repo/database'''
    $content = $content -replace 'from [''"]@/lib/supabase-admin[''"]', 'from ''@repo/database'''
    $content = $content -replace 'from [''"]@/lib/supabase[''"]', 'from ''@repo/database'''
    
    # 2. Utils
    $content = $content -replace 'from [''"]@/lib/utils[''"]', 'from ''@repo/utils'''
    $content = $content -replace 'from [''"]@/lib/formatters[''"]', 'from ''@repo/utils'''
    $content = $content -replace 'from [''"]@/lib/validators[''"]', 'from ''@repo/utils'''
    $content = $content -replace 'from [''"]@/lib/images[''"]', 'from ''@repo/utils'''
    $content = $content -replace 'from [''"]@/lib/products[''"]', 'from ''@repo/utils'''
    $content = $content -replace 'from [''"]@/lib/constants[''"]', 'from ''@repo/utils'''
    
    # 3. Auth
    $content = $content -replace 'from [''"]@/lib/auth/([^''"]*)' , 'from ''@repo/auth'''
    
    # 4. UI Components
    $content = $content -replace 'from [''"]@/components/ui/([^''"]*)[''"]', 'from ''@repo/ui'''
    
    # 5. Sanity
    $content = $content -replace 'from [''"]@/lib/sanity\.client[''"]', 'from ''@repo/sanity'''
    $content = $content -replace 'from [''"]@/lib/sanity\.image[''"]', 'from ''@repo/sanity'''
    $content = $content -replace 'from [''"]@/lib/queries[''"]', 'from ''@repo/sanity'''
    
    # 6. Email
    $content = $content -replace 'from [''"]@/lib/email/([^''"]*)' , 'from ''@repo/email'''
    
    # 7. Shipping
    $content = $content -replace 'from [''"]@/lib/shipping/([^''"]*)' , 'from ''@repo/shipping'''
    
    # 8. Analytics
    $content = $content -replace 'from [''"]@/lib/analytics/([^''"]*)' , 'from ''@repo/analytics'''
    
    # Compter les changements
    if ($content -ne $originalContent) {
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        $filesModified++
        
        $changes = ($originalContent.Length - $content.Replace('from ''@repo/', 'X').Length) - 
                    ($originalContent.Replace('from ''@/', 'X').Length - $content.Length)
        if ($changes -gt 0) {
            $totalFixed += $changes
            $relativePath = $file.FullName.Replace((Get-Location).Path + '\', '')
            Write-Host "  ✅ $relativePath" -ForegroundColor Green
        }
    }
}

Write-Host "
============================================" -ForegroundColor Cyan
Write-Host "  Correction terminée!" -ForegroundColor Green
Write-Host "  Fichiers modifiés: $filesModified" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
