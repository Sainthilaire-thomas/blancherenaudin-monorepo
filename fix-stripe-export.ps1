# ============================================================================
# CORRECTION AUTOMATIQUE - Export stripe dans packages/database/src/index.ts
# ============================================================================

$ProjectRoot = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
$IndexPath = "$ProjectRoot\packages\database\src\index.ts"

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          CORRECTION EXPORT STRIPE - index.ts                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

if (-not (Test-Path $IndexPath)) {
    Write-Host "❌ ERREUR: Fichier $IndexPath introuvable" -ForegroundColor Red
    exit 1
}

Write-Host "📄 Lecture du fichier actuel..." -ForegroundColor Cyan
$Content = Get-Content $IndexPath -Raw

Write-Host "🔍 Recherche de l'export stripe..." -ForegroundColor Cyan

# Patterns à rechercher et supprimer
$PatternsToRemove = @(
    "export \* from ['\`"]\.\/stripe['\`"]\s*;?\s*\r?\n?",
    "export \{ stripe \} from ['\`"]\.\/stripe['\`"]\s*;?\s*\r?\n?",
    "export \{\s*stripe\s*\} from ['\`"]\.\/stripe['\`"]\s*;?\s*\r?\n?"
)

$Modified = $false

foreach ($Pattern in $PatternsToRemove) {
    if ($Content -match $Pattern) {
        Write-Host "  ✅ Export stripe trouvé, suppression..." -ForegroundColor Yellow
        $Content = $Content -replace $Pattern, ""
        $Modified = $true
    }
}

if ($Modified) {
    # Nettoyer les lignes vides multiples
    $Content = $Content -replace "(\r?\n){3,}", "`n`n"
    
    # Sauvegarder
    Write-Host "💾 Sauvegarde de la correction..." -ForegroundColor Cyan
    $Content | Set-Content $IndexPath -NoNewline
    
    Write-Host "`n✅ SUCCÈS: Export stripe supprimé de index.ts" -ForegroundColor Green
    Write-Host "   Le fichier index.ts ne contient plus l'export de stripe" -ForegroundColor Green
    
    Write-Host "`n📋 Contenu final de index.ts:" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Get-Content $IndexPath | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
    
    Write-Host "🔄 Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "   1. Rebuild le package database:" -ForegroundColor White
    Write-Host "      cd packages\database" -ForegroundColor Cyan
    Write-Host "      pnpm run build" -ForegroundColor Cyan
    Write-Host "`n   2. Relancer la vérification:" -ForegroundColor White
    Write-Host "      cd ..\..\" -ForegroundColor Cyan
    Write-Host "      .\verify-project-complete.ps1" -ForegroundColor Cyan
    Write-Host "`n   3. Si OK, démarrer le dev serveur:" -ForegroundColor White
    Write-Host "      cd apps\storefront" -ForegroundColor Cyan
    Write-Host "      Remove-Item -Recurse -Force .next" -ForegroundColor Cyan
    Write-Host "      pnpm dev`n" -ForegroundColor Cyan
    
} else {
    Write-Host "ℹ️  Aucun export stripe trouvé dans index.ts" -ForegroundColor Yellow
    Write-Host "   Le fichier semble déjà correct." -ForegroundColor Yellow
    
    Write-Host "`n📋 Contenu actuel de index.ts:" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Get-Content $IndexPath | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Gray
    }
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Gray
}
