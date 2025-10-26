Write-Host '============================================' -ForegroundColor Cyan
Write-Host '   AUDIT DES IMPORTS @/ RESTANTS' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan

# Trouver tous les imports @/
$files = Get-ChildItem -Path 'apps/storefront' -Include '*.ts','*.tsx' -Recurse -File |
    Select-String -Pattern 'from [''"]@/' |
    Group-Object Path

Write-Host "
Trouvé $($files.Count) fichiers avec des imports @/
" -ForegroundColor Yellow

# Analyser chaque fichier
$importsByType = @{}

foreach ($file in $files) {
    $relativePath = $file.Name.Replace((Get-Location).Path + '\', '')
    Write-Host "
📄 $relativePath" -ForegroundColor Cyan
    Write-Host "   ($($file.Count) imports)
" -ForegroundColor Gray
    
    # Extraire les imports
    $imports = Get-Content $file.Name | Select-String -Pattern 'from [''"]@/([^''"]*)' -AllMatches
    
    foreach ($import in $imports) {
        foreach ($match in $import.Matches) {
            $importPath = $match.Groups[1].Value
            
            # Déterminer le package cible
            $targetPackage = 'UNKNOWN'
            $suggestion = ''
            
            if ($importPath -match '^lib/supabase') {
                $targetPackage = '@repo/database'
                $suggestion = 'import { ... } from ''@repo/database'''
            }
            elseif ($importPath -match '^lib/sanity') {
                $targetPackage = '@repo/sanity'
                $suggestion = 'import { ... } from ''@repo/sanity'''
            }
            elseif ($importPath -match '^lib/stripe') {
                $targetPackage = 'storefront/lib'
                $suggestion = 'import { ... } from ''@/lib/stripe'' (OK si dans storefront/lib)'
            }
            elseif ($importPath -match '^lib/(utils|formatters|validators|images|products|constants)') {
                $targetPackage = '@repo/utils'
                $suggestion = 'import { ... } from ''@repo/utils'''
            }
            elseif ($importPath -match '^lib/auth') {
                $targetPackage = '@repo/auth'
                $suggestion = 'import { ... } from ''@repo/auth'''
            }
            elseif ($importPath -match '^lib/email') {
                $targetPackage = '@repo/email'
                $suggestion = 'import { ... } from ''@repo/email'''
            }
            elseif ($importPath -match '^lib/shipping') {
                $targetPackage = '@repo/shipping'
                $suggestion = 'import { ... } from ''@repo/shipping'''
            }
            elseif ($importPath -match '^lib/analytics') {
                $targetPackage = '@repo/analytics'
                $suggestion = 'import { ... } from ''@repo/analytics'''
            }
            elseif ($importPath -match '^components/ui') {
                $targetPackage = '@repo/ui'
                $suggestion = 'import { ... } from ''@repo/ui'''
            }
            elseif ($importPath -match '^components/') {
                $targetPackage = 'storefront/components'
                $suggestion = 'import { ... } from ''@/components/...'' (OK si app-specific)'
            }
            elseif ($importPath -match '^store/') {
                $targetPackage = 'storefront/store'
                $suggestion = 'import { ... } from ''@/store/...'' (OK)'
            }
            elseif ($importPath -match '^hooks/') {
                $targetPackage = '@repo/ui ou storefront'
                $suggestion = 'Vérifier si dans @repo/ui ou app-specific'
            }
            elseif ($importPath -match '^app/') {
                $targetPackage = 'OK'
                $suggestion = 'Import Next.js App Router (OK)'
            }
            
            Write-Host "   ❌ @/$importPath" -ForegroundColor Red
            Write-Host "      → $suggestion" -ForegroundColor Yellow
            
            # Compter par type
            if (-not $importsByType.ContainsKey($targetPackage)) {
                $importsByType[$targetPackage] = 0
            }
            $importsByType[$targetPackage]++
        }
    }
}

# Résumé
Write-Host "
============================================" -ForegroundColor Cyan
Write-Host '   RÉSUMÉ PAR PACKAGE CIBLE' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan

foreach ($pkg in $importsByType.Keys | Sort-Object) {
    $count = $importsByType[$pkg]
    Write-Host "
$pkg : $count imports" -ForegroundColor Yellow
}

Write-Host "
============================================" -ForegroundColor Cyan
