# Script de nettoyage - Blanche Renaudin Monorepo
# Date: 2 novembre 2025
# Objectif: Nettoyer les fichiers de test et l'architecture obsolète

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🧹 Nettoyage du monorepo" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$ROOT = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

# Fonction pour supprimer en sécurité
function Remove-SafeItem {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path $Path) {
        Write-Host "🗑️  Suppression: $Description" -ForegroundColor Yellow
        Write-Host "   Chemin: $Path" -ForegroundColor Gray
        Remove-Item $Path -Recurse -Force
        Write-Host "   ✅ Supprimé" -ForegroundColor Green
    } else {
        Write-Host "⏭️  Déjà absent: $Description" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "📋 Étape 1: Suppression des fichiers de test" -ForegroundColor Yellow
Write-Host ""

# Fichiers de test créés pendant le debug
Remove-SafeItem "$ROOT\apps\admin\app\test-tool" "Page de test test-tool"
Remove-SafeItem "$ROOT\apps\admin\app\categories-test" "Page de test categories-test"
Remove-SafeItem "$ROOT\packages\tools\test-tool" "Package test-tool (POC)"
Remove-SafeItem "$ROOT\apps\admin\app\(tools)\layout.tsx.bak" "Backup layout (tools)"

Write-Host "📋 Étape 2: Packages obsolètes de l'ancienne architecture" -ForegroundColor Yellow
Write-Host ""

# Admin-shell n'est plus utilisé (logique intégrée dans apps/admin)
Remove-SafeItem "$ROOT\packages\admin-shell" "Package admin-shell (obsolète)"

Write-Host "📋 Étape 3: Vérification des dépendances dans package.json" -ForegroundColor Yellow
Write-Host ""

$packageJsonPath = "$ROOT\apps\admin\package.json"

if (Test-Path $packageJsonPath) {
    Write-Host "📝 Lecture de apps/admin/package.json..." -ForegroundColor Cyan
    
    $packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
    
    $toRemove = @()
    
    # Vérifier les dépendances obsolètes
    if ($packageJson.dependencies.'@repo/admin-shell') {
        $toRemove += '@repo/admin-shell'
    }
    if ($packageJson.dependencies.'@repo/tools-test') {
        $toRemove += '@repo/tools-test'
    }
    
    if ($toRemove.Count -gt 0) {
        Write-Host "⚠️  Dépendances obsolètes trouvées:" -ForegroundColor Yellow
        foreach ($dep in $toRemove) {
            Write-Host "   - $dep" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "📝 Pour les supprimer, exécutez:" -ForegroundColor Cyan
        Write-Host "   cd apps/admin" -ForegroundColor White
        foreach ($dep in $toRemove) {
            Write-Host "   pnpm remove $dep" -ForegroundColor White
        }
    } else {
        Write-Host "✅ Aucune dépendance obsolète trouvée" -ForegroundColor Green
    }
} else {
    Write-Host "❌ apps/admin/package.json introuvable" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Étape 4: Nettoyage des caches" -ForegroundColor Yellow
Write-Host ""

Remove-SafeItem "$ROOT\apps\admin\.next" "Cache Next.js admin"
Remove-SafeItem "$ROOT\apps\storefront\.next" "Cache Next.js storefront"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 Résumé du nettoyage" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Fichiers de test supprimés" -ForegroundColor Green
Write-Host "✅ Packages obsolètes supprimés" -ForegroundColor Green
Write-Host "✅ Caches nettoyés" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Prochaines étapes recommandées:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Vérifier les dépendances:" -ForegroundColor White
Write-Host "   cd apps/admin" -ForegroundColor Gray
Write-Host "   pnpm remove @repo/tools-test @repo/admin-shell" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Réinstaller les dépendances:" -ForegroundColor White
Write-Host "   pnpm install" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Rebuild et tester:" -ForegroundColor White
Write-Host "   pnpm build" -ForegroundColor Gray
Write-Host "   pnpm dev" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Commit les changements:" -ForegroundColor White
Write-Host "   git add ." -ForegroundColor Gray
Write-Host "   git commit -m 'chore: nettoyage fichiers test et packages obsolètes'" -ForegroundColor Gray
Write-Host ""

# Pause pour lire
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
