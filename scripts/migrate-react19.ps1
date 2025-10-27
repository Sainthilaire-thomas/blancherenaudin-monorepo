# migrate-react19.ps1
# Script de migration automatique vers React 19
# Blanche Renaudin Monorepo
# Date: 27 octobre 2025

# Configuration
$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
$ErrorActionPreference = "Continue"

# Couleurs pour l'affichage
function Write-Success { param($msg) Write-Host "✅ $msg" -ForegroundColor Green }
function Write-Info { param($msg) Write-Host "ℹ️  $msg" -ForegroundColor Cyan }
function Write-Warning { param($msg) Write-Host "⚠️  $msg" -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host "❌ $msg" -ForegroundColor Red }
function Write-Step { param($msg) Write-Host "`n📦 $msg" -ForegroundColor Yellow }

# Banner
Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🚀 Migration vers React 19 - Blanche Renaudin" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Vérifier que le monorepo existe
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Error "Monorepo introuvable à $MONOREPO_PATH"
    Write-Warning "Veuillez modifier la variable `$MONOREPO_PATH dans le script"
    exit 1
}

Set-Location $MONOREPO_PATH
Write-Success "Monorepo trouvé: $MONOREPO_PATH`n"

# ═══════════════════════════════════════════════════════
# ÉTAPE 1: Modifier @repo/ui peerDependencies
# ═══════════════════════════════════════════════════════
Write-Step "Étape 1/5: Mise à jour @repo/ui peerDependencies"

$uiPkgPath = ".\packages\ui\package.json"

if (-Not (Test-Path $uiPkgPath)) {
    Write-Error "Fichier introuvable: $uiPkgPath"
    exit 1
}

# Backup du fichier
$backupPath = "$uiPkgPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item $uiPkgPath $backupPath
Write-Info "Backup créé: $(Split-Path $backupPath -Leaf)"

# Lire et modifier le contenu
$content = Get-Content $uiPkgPath -Raw

# Vérifier si déjà à jour
if ($content -match '"react":\s*"\^18\.0\.0\s*\|\|\s*\^19\.0\.0"') {
    Write-Info "@repo/ui est déjà compatible React 18+19, passage à l'étape suivante"
} else {
    # Remplacer les peerDependencies
    $content = $content -replace '"react":\s*"\^18\.0\.0"', '"react": "^18.0.0 || ^19.0.0"'
    $content = $content -replace '"react-dom":\s*"\^18\.0\.0"', '"react-dom": "^18.0.0 || ^19.0.0"'
    
    # Sauvegarder
    $content | Set-Content $uiPkgPath -NoNewline
    Write-Success "@repo/ui mis à jour pour accepter React 18 ET 19"
}

# ═══════════════════════════════════════════════════════
# ÉTAPE 2: Migrer apps/admin vers React 19
# ═══════════════════════════════════════════════════════
Write-Step "Étape 2/5: Migration apps/admin vers React 19"

$adminPkgPath = ".\apps\admin\package.json"

if (-Not (Test-Path $adminPkgPath)) {
    Write-Warning "apps/admin/package.json introuvable, passage à l'étape suivante"
} else {
    # Vérifier la version actuelle
    $adminPkg = Get-Content $adminPkgPath -Raw | ConvertFrom-Json
    $currentReactVersion = $adminPkg.dependencies.react
    
    Write-Info "Version React actuelle dans admin: $currentReactVersion"
    
    if ($currentReactVersion -match "19\.") {
        Write-Info "apps/admin est déjà en React 19, passage à l'étape suivante"
    } else {
        Write-Info "Migration de apps/admin vers React 19..."
        
        # Exécuter pnpm add
        $process = Start-Process -FilePath "pnpm" -ArgumentList "--filter", "admin", "add", "react@^19.0.0", "react-dom@^19.0.0" -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Success "apps/admin migré vers React 19"
        } else {
            Write-Error "Erreur lors de la migration de apps/admin (code: $($process.ExitCode))"
            Write-Warning "Continuons quand même..."
        }
    }
}

# ═══════════════════════════════════════════════════════
# ÉTAPE 3: Migrer apps/storefront vers React 19
# ═══════════════════════════════════════════════════════
Write-Step "Étape 3/5: Migration apps/storefront vers React 19"

$storefrontPkgPath = ".\apps\storefront\package.json"

if (-Not (Test-Path $storefrontPkgPath)) {
    Write-Warning "apps/storefront/package.json introuvable, passage à l'étape suivante"
} else {
    # Vérifier la version actuelle
    $storefrontPkg = Get-Content $storefrontPkgPath -Raw | ConvertFrom-Json
    $currentReactVersion = $storefrontPkg.dependencies.react
    
    Write-Info "Version React actuelle dans storefront: $currentReactVersion"
    
    if ($currentReactVersion -match "19\.") {
        Write-Info "apps/storefront est déjà en React 19, passage à l'étape suivante"
    } else {
        Write-Info "Migration de apps/storefront vers React 19..."
        
        # Exécuter pnpm add
        $process = Start-Process -FilePath "pnpm" -ArgumentList "--filter", "storefront", "add", "react@^19.0.0", "react-dom@^19.0.0" -NoNewWindow -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Success "apps/storefront migré vers React 19"
        } else {
            Write-Error "Erreur lors de la migration de apps/storefront (code: $($process.ExitCode))"
            Write-Warning "Continuons quand même..."
        }
    }
}

# ═══════════════════════════════════════════════════════
# ÉTAPE 4: Réinstaller toutes les dépendances
# ═══════════════════════════════════════════════════════
Write-Step "Étape 4/5: Réinstallation des dépendances"

Write-Info "Exécution de 'pnpm install'..."
$process = Start-Process -FilePath "pnpm" -ArgumentList "install" -NoNewWindow -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Success "Dépendances réinstallées avec succès"
} else {
    Write-Error "Erreur lors de la réinstallation (code: $($process.ExitCode))"
    Write-Warning "Vérifiez les logs ci-dessus"
}

# ═══════════════════════════════════════════════════════
# ÉTAPE 5: Audit final
# ═══════════════════════════════════════════════════════
Write-Step "Étape 5/5: Audit final des versions React"

$packages = @(
    @{ Name = "@repo/ui"; Path = ".\packages\ui\package.json" },
    @{ Name = "@repo/admin-shell"; Path = ".\packages\admin-shell\package.json" },
    @{ Name = "@repo/analytics"; Path = ".\packages\analytics\package.json" },
    @{ Name = "@repo/email"; Path = ".\packages\email\package.json" },
    @{ Name = "@repo/newsletter"; Path = ".\packages\newsletter\package.json" },
    @{ Name = "apps/admin"; Path = ".\apps\admin\package.json" },
    @{ Name = "apps/storefront"; Path = ".\apps\storefront\package.json" }
)

Write-Host "`n┌─────────────────────────┬───────────────────┐" -ForegroundColor Cyan
Write-Host "│ Package                 │ React Version     │" -ForegroundColor Cyan
Write-Host "├─────────────────────────┼───────────────────┤" -ForegroundColor Cyan

$react19Count = 0
$react18Count = 0
$compatibleCount = 0

foreach ($pkg in $packages) {
    if (Test-Path $pkg.Path) {
        $json = Get-Content $pkg.Path -Raw | ConvertFrom-Json
        
        # Vérifier dependencies ou peerDependencies
        $reactVersion = $null
        if ($json.dependencies -and $json.dependencies.react) {
            $reactVersion = $json.dependencies.react
        } elseif ($json.peerDependencies -and $json.peerDependencies.react) {
            $reactVersion = $json.peerDependencies.react
        }
        
        if ($reactVersion) {
            $status = ""
            $color = "White"
            
            if ($reactVersion -match "19\.") {
                $status = "19.x"
                $color = "Green"
                $react19Count++
            } elseif ($reactVersion -match "18\." -and $reactVersion -notmatch "\|\|") {
                $status = "18.x only"
                $color = "Yellow"
                $react18Count++
            } elseif ($reactVersion -match "\|\|") {
                $status = "18+19 compat"
                $color = "Cyan"
                $compatibleCount++
            }
            
            $nameFormatted = $pkg.Name.PadRight(23)
            $versionFormatted = $status.PadRight(17)
            Write-Host "│ $nameFormatted │ " -NoNewline -ForegroundColor White
            Write-Host "$versionFormatted" -NoNewline -ForegroundColor $color
            Write-Host " │" -ForegroundColor White
        }
    }
}

Write-Host "└─────────────────────────┴───────────────────┘" -ForegroundColor Cyan

# ═══════════════════════════════════════════════════════
# RÉSUMÉ
# ═══════════════════════════════════════════════════════
Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 RÉSUMÉ DE LA MIGRATION" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "React 19 uniquement:       $react19Count" -ForegroundColor $(if ($react19Count -gt 0) { "Green" } else { "White" })
Write-Host "React 18 uniquement:       $react18Count" -ForegroundColor $(if ($react18Count -eq 0) { "Green" } else { "Yellow" })
Write-Host "Compatible 18+19:          $compatibleCount" -ForegroundColor Cyan

Write-Host ""

if ($react18Count -eq 0) {
    Write-Host "✅ EXCELLENT! Tout est compatible React 19!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 Migration réussie!" -ForegroundColor Green
} else {
    Write-Warning "Il reste $react18Count package(s) en React 18"
    Write-Host ""
    Write-Host "⚠️  Migration partielle - vérification manuelle requise" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🧪 PROCHAINES ÉTAPES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "1. Vérifier la compilation TypeScript:" -ForegroundColor White
Write-Host "   pnpm type-check`n" -ForegroundColor Gray

Write-Host "2. Build les applications:" -ForegroundColor White
Write-Host "   pnpm --filter admin build" -ForegroundColor Gray
Write-Host "   pnpm --filter storefront build`n" -ForegroundColor Gray

Write-Host "3. Tester en mode développement:" -ForegroundColor White
Write-Host "   pnpm --filter admin dev" -ForegroundColor Gray
Write-Host "   pnpm --filter storefront dev`n" -ForegroundColor Gray

Write-Host "4. Tester les fonctionnalités critiques:" -ForegroundColor White
Write-Host "   ✓ Admin: dashboard, /products" -ForegroundColor Gray
Write-Host "   ✓ Storefront: homepage, /products, checkout`n" -ForegroundColor Gray

Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Fichiers de backup créés
if (Test-Path $backupPath) {
    Write-Info "Backup disponible: $backupPath"
    Write-Host ""
}

Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
