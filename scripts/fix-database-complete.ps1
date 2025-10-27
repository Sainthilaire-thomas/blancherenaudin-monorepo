# Script COMPLET de correction des imports database
Write-Host "`n=== CORRECTION COMPLETE DATABASE ===" -ForegroundColor Cyan
Write-Host "Etape 1: Correction des chemins d'imports" -ForegroundColor Yellow
Write-Host "Etape 2: Correction des noms de fonctions`n" -ForegroundColor Yellow

Set-Location "apps\storefront\app"
Write-Host "Dossier: $(Get-Location)`n" -ForegroundColor Gray

$allFiles = Get-ChildItem -Recurse -Include "*.tsx", "*.ts" -File
Write-Host "Fichiers trouves: $($allFiles.Count)`n" -ForegroundColor Green

$totalModified = 0

# ========================================
# ETAPE 1: Corriger les chemins d'imports
# ========================================
Write-Host "`n--- ETAPE 1: Chemins d'imports ---`n" -ForegroundColor Cyan

$pathReplacements = @{
    "@blancherenaudin/database/supabase-server" = "@repo/database"
    "@blancherenaudin/database/supabase-browser" = "@repo/database"
    "@blancherenaudin/database/supabase-admin" = "@repo/database"
    "@blancherenaudin/database/types" = "@repo/database/types"
}

foreach ($oldPath in $pathReplacements.Keys) {
    $newPath = $pathReplacements[$oldPath]
    Write-Host "Remplacement: '$oldPath' -> '$newPath'" -ForegroundColor Cyan
    
    $count = 0
    foreach ($file in $allFiles) {
        try {
            if (-not (Test-Path -LiteralPath $file.FullName)) { continue }
            
            $content = Get-Content -LiteralPath $file.FullName
            $lines = @($content)
            $modified = $false
            
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match [regex]::Escape($oldPath)) {
                    $lines[$i] = $lines[$i] -replace [regex]::Escape($oldPath), $newPath
                    $modified = $true
                }
            }
            
            if ($modified) {
                Set-Content -LiteralPath $file.FullName -Value $lines
                $count++
            }
        }
        catch {
            Write-Host "   ERREUR: $($file.Name)" -ForegroundColor Red
        }
    }
    
    if ($count -gt 0) {
        Write-Host "   => $count fichier(s) modifie(s)" -ForegroundColor Green
        $totalModified += $count
    } else {
        Write-Host "   => Aucun fichier modifie" -ForegroundColor DarkGray
    }
}

# ========================================
# ETAPE 2: Corriger les noms de fonctions
# ========================================
Write-Host "`n--- ETAPE 2: Noms de fonctions ---`n" -ForegroundColor Cyan

$functionReplacements = @{
    "getServerSupabase" = "createServerClient"
    "getBrowserSupabase" = "createBrowserClient"
}

foreach ($oldFunc in $functionReplacements.Keys) {
    $newFunc = $functionReplacements[$oldFunc]
    Write-Host "Remplacement: '$oldFunc' -> '$newFunc'" -ForegroundColor Cyan
    
    $count = 0
    foreach ($file in $allFiles) {
        try {
            if (-not (Test-Path -LiteralPath $file.FullName)) { continue }
            
            $content = Get-Content -LiteralPath $file.FullName
            $lines = @($content)
            $modified = $false
            
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match $oldFunc) {
                    $lines[$i] = $lines[$i] -replace $oldFunc, $newFunc
                    $modified = $true
                }
            }
            
            if ($modified) {
                Set-Content -LiteralPath $file.FullName -Value $lines
                $count++
                Write-Host "   OK: $($file.Name)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "   ERREUR: $($file.Name)" -ForegroundColor Red
        }
    }
    
    if ($count -gt 0) {
        Write-Host "   => $count fichier(s) modifie(s)" -ForegroundColor Green
        $totalModified += $count
    } else {
        Write-Host "   => Aucun fichier modifie" -ForegroundColor DarkGray
    }
}

Write-Host "`n=== TERMINE - $totalModified modifications ===" -ForegroundColor Green

Set-Location "..\..\.."

Write-Host "`nProchaines etapes:" -ForegroundColor Cyan
Write-Host "1. Verifier les erreurs eventuelles" -ForegroundColor White
Write-Host "2. Rebuild: cd apps\storefront && pnpm dev" -ForegroundColor White
Write-Host ""
