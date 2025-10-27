# complete-admin-shell.ps1
# Script de finalisation Admin Shell App
# Blanche Renaudin Monorepo

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🎯 Finalisation Admin Shell App - Phase 8" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

# Vérifier le monorepo
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "❌ Monorepo introuvable: $MONOREPO_PATH" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Monorepo trouvé" -ForegroundColor Green
Write-Host ""

# Étape 1: Créer les dossiers manquants
Write-Host "📁 Étape 1: Création des dossiers..." -ForegroundColor Yellow

$FOLDERS = @(
    "apps\admin\app\(dashboard)\[module]",
    "apps\admin\app\(dashboard)\[module]\[[...slug]]"
)

foreach ($folder in $FOLDERS) {
    $fullPath = Join-Path $MONOREPO_PATH $folder
    if (-Not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "   ✅ Créé: $folder" -ForegroundColor Green
    } else {
        Write-Host "   ⏭️  Existe: $folder" -ForegroundColor Gray
    }
}

Write-Host ""

# Étape 2: Copier les fichiers
Write-Host "📋 Étape 2: Installation des fichiers..." -ForegroundColor Yellow

# Fonction de copie
function Copy-WithBackup {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description
    )
    
    if (Test-Path $Source) {
        # Backup si existe
        if (Test-Path $Destination) {
            $backup = "$Destination.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $Destination $backup -Force
            Write-Host "   💾 Backup: $(Split-Path $backup -Leaf)" -ForegroundColor Cyan
        }
        
        Copy-Item $Source $Destination -Force
        Write-Host "   ✅ $Description" -ForegroundColor Green
        return $true
    } else {
        Write-Host "   ❌ Fichier source manquant: $Source" -ForegroundColor Red
        return $false
    }
}

$DOWNLOADS = "$env:USERPROFILE\Downloads"

$FILES = @{
    "module-slug-page.tsx" = @{
        dest = "apps\admin\app\(dashboard)\[module]\[[...slug]]\page.tsx"
        desc = "Route dynamique modules"
    }
    "tsconfig.json" = @{
        dest = "apps\admin\tsconfig.json"
        desc = "TypeScript config avec paths"
    }
}

$success = 0
$total = $FILES.Count

foreach ($file in $FILES.GetEnumerator()) {
    $source = Join-Path $DOWNLOADS $file.Key
    $dest = Join-Path $MONOREPO_PATH $file.Value.dest
    
    if (Copy-WithBackup -Source $source -Destination $dest -Description $file.Value.desc) {
        $success++
    }
}

Write-Host ""

# Étape 3: Vérification finale
Write-Host "🔍 Étape 3: Vérification finale..." -ForegroundColor Yellow

$routePath = Join-Path $MONOREPO_PATH "apps\admin\app\(dashboard)\[module]\[[...slug]]\page.tsx"
$tsconfigPath = Join-Path $MONOREPO_PATH "apps\admin\tsconfig.json"

$allGood = $true

if (Test-Path $routePath) {
    Write-Host "   ✅ Route dynamique installée" -ForegroundColor Green
} else {
    Write-Host "   ❌ Route dynamique manquante" -ForegroundColor Red
    $allGood = $false
}

if (Test-Path $tsconfigPath) {
    $content = Get-Content $tsconfigPath -Raw
    if ($content -match "@repo/") {
        Write-Host "   ✅ TypeScript paths configurés" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  TypeScript paths non configurés" -ForegroundColor Yellow
        $allGood = $false
    }
} else {
    Write-Host "   ❌ tsconfig.json manquant" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""

# Résumé final
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 RÉSUMÉ FINAL" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

if ($allGood -and $success -eq $total) {
    Write-Host "✅ Installation COMPLÈTE à 100% !" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "   1. cd apps/admin" -ForegroundColor White
    Write-Host "   2. pnpm dev" -ForegroundColor White
    Write-Host "   3. Ouvrir http://localhost:3001" -ForegroundColor White
    Write-Host "   4. Tester la navigation entre modules" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "⚠️  Installation PARTIELLE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Fichiers manquants:" -ForegroundColor Red
    foreach ($file in $FILES.GetEnumerator()) {
        $source = Join-Path $DOWNLOADS $file.Key
        if (-Not (Test-Path $source)) {
            Write-Host "   - $($file.Key)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "📖 Documentation: ARCHITECTURE-migration-archi-modulaire.md" -ForegroundColor Cyan
Write-Host ""

# Attendre avant fermeture
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
