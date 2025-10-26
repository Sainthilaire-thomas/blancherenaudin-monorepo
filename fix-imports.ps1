# Script de correction des imports - Version qui gere les crochets
Write-Host "`n--- Correction des imports dans storefront ---`n" -ForegroundColor Cyan

Set-Location "apps\storefront\app"
Write-Host "Dossier actuel: $(Get-Location)`n" -ForegroundColor Gray

# Definir les remplacements
$replacements = @{
    "@/components/ui/" = "@blancherenaudin/ui/"
    "from '@/components/ui/" = "from '@blancherenaudin/ui/"
    "@/lib/supabase-server" = "@blancherenaudin/database/supabase-server"
    "@/lib/supabase-browser" = "@blancherenaudin/database/supabase-browser"
    "@/lib/supabase-admin" = "@blancherenaudin/database/supabase-admin"
    "@/lib/database.types" = "@blancherenaudin/database/types"
    "@/lib/sanity.client" = "@blancherenaudin/sanity/client"
    "@/lib/sanity.image" = "@blancherenaudin/sanity/image"
    "@/lib/queries" = "@blancherenaudin/sanity/queries"
    "@/lib/email/" = "@blancherenaudin/email/"
    "@/lib/stripe" = "@blancherenaudin/payments/stripe"
}

# Compter les fichiers (avec -LiteralPath pour gerer les crochets)
$allFiles = Get-ChildItem -Recurse -Include "*.tsx", "*.ts" -File
Write-Host "Fichiers trouves: $($allFiles.Count)`n" -ForegroundColor Green

$totalModified = 0

# Pour chaque remplacement
foreach ($oldPattern in $replacements.Keys) {
    $newPattern = $replacements[$oldPattern]
    
    Write-Host "Traitement: '$oldPattern' -> '$newPattern'" -ForegroundColor Cyan
    
    $count = 0
    
    # Pour chaque fichier
    foreach ($file in $allFiles) {
        try {
            # Verifier que le fichier existe REELLEMENT
            if (-not (Test-Path -LiteralPath $file.FullName)) {
                continue
            }
            
            # Lire le contenu avec -LiteralPath
            $content = Get-Content -LiteralPath $file.FullName
            $lines = @($content)
            $modified = $false
            
            # Remplacer dans chaque ligne
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match [regex]::Escape($oldPattern)) {
                    $lines[$i] = $lines[$i] -replace [regex]::Escape($oldPattern), $newPattern
                    $modified = $true
                }
            }
            
            # Si modifie, sauvegarder avec -LiteralPath
            if ($modified) {
                Set-Content -LiteralPath $file.FullName -Value $lines
                $count++
                Write-Host "   OK: $($file.Name)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "   ERREUR: $($file.Name) - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    
    if ($count -gt 0) {
        Write-Host "   => $count fichier(s) modifie(s)`n" -ForegroundColor Green
        $totalModified += $count
    } else {
        Write-Host "   => Aucun fichier modifie`n" -ForegroundColor DarkGray
    }
}

Write-Host "`n=== TERMINE - $totalModified modifications au total ===`n" -ForegroundColor Green

Set-Location "..\..\.."

Write-Host "Prochaines etapes:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Re-verifier les imports:" -ForegroundColor White
Write-Host "   .\verif-imports-v2.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Si tout est OK, rebuild:" -ForegroundColor White
Write-Host "   cd apps\storefront" -ForegroundColor Gray
Write-Host "   Remove-Item -Recurse -Force .next -ErrorAction SilentlyContinue" -ForegroundColor Gray
Write-Host "   pnpm dev" -ForegroundColor Gray
Write-Host ""
