# check-admin-shell.ps1
# Script de vérification de l'installation Admin Shell
# Date: 27 octobre 2025

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🔍 Vérification Admin Shell - Blanche Renaudin" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Configuration
$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
$PACKAGE_PATH = Join-Path $MONOREPO_PATH "packages\admin-shell"

# Couleurs pour les résultats
$SUCCESS = "Green"
$ERROR = "Red"
$WARNING = "Yellow"
$INFO = "Cyan"

# Compteurs
$totalChecks = 0
$passedChecks = 0
$failedChecks = 0

# Fonction de vérification
function Test-Item {
    param(
        [string]$Path,
        [string]$Description,
        [switch]$IsDirectory
    )
    
    $global:totalChecks++
    
    if (Test-Path $Path) {
        if ($IsDirectory) {
            $type = "📁"
        } else {
            $type = "📄"
        }
        Write-Host "   ✅ $type $Description" -ForegroundColor $SUCCESS
        $global:passedChecks++
        return $true
    } else {
        Write-Host "   ❌ $Description manquant" -ForegroundColor $ERROR
        Write-Host "      Path: $Path" -ForegroundColor Gray
        $global:failedChecks++
        return $false
    }
}

# Fonction de vérification de contenu
function Test-FileContent {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Description
    )
    
    $global:totalChecks++
    
    if (Test-Path $Path) {
        $content = Get-Content $Path -Raw
        if ($content -match $Pattern) {
            Write-Host "   ✅ $Description" -ForegroundColor $SUCCESS
            $global:passedChecks++
            return $true
        } else {
            Write-Host "   ❌ $Description manquant dans le fichier" -ForegroundColor $ERROR
            Write-Host "      Expected pattern: $Pattern" -ForegroundColor Gray
            $global:failedChecks++
            return $false
        }
    } else {
        Write-Host "   ❌ Fichier $Path introuvable" -ForegroundColor $ERROR
        $global:failedChecks++
        return $false
    }
}

# ═══════════════════════════════════════════════════════════
# VÉRIFICATIONS
# ═══════════════════════════════════════════════════════════

Write-Host "🔍 Démarrage des vérifications..." -ForegroundColor $INFO
Write-Host ""

# Check 1: Monorepo existe
Write-Host "1️⃣  Vérification du monorepo..." -ForegroundColor $INFO
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "   ❌ Monorepo introuvable à $MONOREPO_PATH" -ForegroundColor $ERROR
    Write-Host ""
    exit 1
}
Write-Host "   ✅ Monorepo trouvé" -ForegroundColor $SUCCESS
Write-Host ""

# Check 2: Package existe
Write-Host "2️⃣  Vérification de la structure du package..." -ForegroundColor $INFO
Test-Item -Path $PACKAGE_PATH -Description "packages/admin-shell/" -IsDirectory

# Vérifier les dossiers principaux
Test-Item -Path (Join-Path $PACKAGE_PATH "src") -Description "src/" -IsDirectory
Test-Item -Path (Join-Path $PACKAGE_PATH "src\types") -Description "src/types/" -IsDirectory
Test-Item -Path (Join-Path $PACKAGE_PATH "src\components") -Description "src/components/" -IsDirectory
Test-Item -Path (Join-Path $PACKAGE_PATH "src\hooks") -Description "src/hooks/" -IsDirectory
Test-Item -Path (Join-Path $PACKAGE_PATH "src\contexts") -Description "src/contexts/" -IsDirectory
Write-Host ""

# Check 3: Fichiers de configuration
Write-Host "3️⃣  Vérification des fichiers de configuration..." -ForegroundColor $INFO
Test-Item -Path (Join-Path $PACKAGE_PATH "package.json") -Description "package.json"
Test-Item -Path (Join-Path $PACKAGE_PATH "tsconfig.json") -Description "tsconfig.json"
Test-Item -Path (Join-Path $PACKAGE_PATH "README.md") -Description "README.md"
Write-Host ""

# Check 4: Fichiers TypeScript - Types
Write-Host "4️⃣  Vérification des types TypeScript..." -ForegroundColor $INFO
Test-Item -Path (Join-Path $PACKAGE_PATH "src\types\module.ts") -Description "module.ts"
Test-Item -Path (Join-Path $PACKAGE_PATH "src\types\services.ts") -Description "services.ts"
Test-Item -Path (Join-Path $PACKAGE_PATH "src\types\index.ts") -Description "types/index.ts"
Write-Host ""

# Check 5: Fichiers TypeScript - Composants
Write-Host "5️⃣  Vérification des composants..." -ForegroundColor $INFO
Test-Item -Path (Join-Path $PACKAGE_PATH "src\components\ModuleLoader.tsx") -Description "ModuleLoader.tsx"
Test-Item -Path (Join-Path $PACKAGE_PATH "src\components\AdminLayout.tsx") -Description "AdminLayout.tsx"
Test-Item -Path (Join-Path $PACKAGE_PATH "src\components\AdminNav.tsx") -Description "AdminNav.tsx"
Test-Item -Path (Join-Path $PACKAGE_PATH "src\components\index.ts") -Description "components/index.ts"
Write-Host ""

# Check 6: Fichier index principal
Write-Host "6️⃣  Vérification de l'index principal..." -ForegroundColor $INFO
Test-Item -Path (Join-Path $PACKAGE_PATH "src\index.ts") -Description "src/index.ts"
Write-Host ""

# Check 7: Contenu package.json
Write-Host "7️⃣  Vérification du contenu de package.json..." -ForegroundColor $INFO
$packageJsonPath = Join-Path $PACKAGE_PATH "package.json"
Test-FileContent -Path $packageJsonPath -Pattern '@repo/admin-shell' -Description "Nom du package"
Test-FileContent -Path $packageJsonPath -Pattern '@repo/ui' -Description "Dépendance @repo/ui"
Test-FileContent -Path $packageJsonPath -Pattern 'lucide-react' -Description "Dépendance lucide-react"
Write-Host ""

# Check 8: Contenu des types
Write-Host "8️⃣  Vérification du contenu des types..." -ForegroundColor $INFO
$moduleTypesPath = Join-Path $PACKAGE_PATH "src\types\module.ts"
Test-FileContent -Path $moduleTypesPath -Pattern 'ModuleDefinition' -Description "Interface ModuleDefinition"
Test-FileContent -Path $moduleTypesPath -Pattern 'RouteDefinition' -Description "Interface RouteDefinition"

$servicesTypesPath = Join-Path $PACKAGE_PATH "src\types\services.ts"
Test-FileContent -Path $servicesTypesPath -Pattern 'ModuleServices' -Description "Interface ModuleServices"
Test-FileContent -Path $servicesTypesPath -Pattern 'ModuleProps' -Description "Interface ModuleProps"
Write-Host ""

# Check 9: Contenu des composants
Write-Host "9️⃣  Vérification du contenu des composants..." -ForegroundColor $INFO
$moduleLoaderPath = Join-Path $PACKAGE_PATH "src\components\ModuleLoader.tsx"
Test-FileContent -Path $moduleLoaderPath -Pattern "export function ModuleLoader" -Description "Export ModuleLoader"
Test-FileContent -Path $moduleLoaderPath -Pattern "services\\.notify" -Description "Service notify"
Test-FileContent -Path $moduleLoaderPath -Pattern "services\\.confirm" -Description "Service confirm"
Test-FileContent -Path $moduleLoaderPath -Pattern "services\\.navigate" -Description "Service navigate"

$adminLayoutPath = Join-Path $PACKAGE_PATH "src\components\AdminLayout.tsx"
Test-FileContent -Path $adminLayoutPath -Pattern "export function AdminLayout" -Description "Export AdminLayout"
Test-FileContent -Path $adminLayoutPath -Pattern "modules:" -Description "Props modules"
Write-Host ""

# Check 10: Exports
Write-Host "🔟 Vérification des exports..." -ForegroundColor $INFO
$mainIndexPath = Join-Path $PACKAGE_PATH "src\index.ts"
Test-FileContent -Path $mainIndexPath -Pattern "export \* from '\./types'" -Description "Export types"
Test-FileContent -Path $mainIndexPath -Pattern "export \* from '\./components'" -Description "Export components"
Write-Host ""

# Check 11: Compilation TypeScript
Write-Host "1️⃣1️⃣  Vérification de la compilation TypeScript..." -ForegroundColor $INFO
$totalChecks++

Push-Location $PACKAGE_PATH

try {
    $output = & pnpm type-check 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -eq 0) {
        Write-Host "   ✅ Compilation TypeScript réussie" -ForegroundColor $SUCCESS
        $passedChecks++
    } else {
        Write-Host "   ❌ Erreurs de compilation TypeScript" -ForegroundColor $ERROR
        Write-Host $output -ForegroundColor Gray
        $failedChecks++
    }
} catch {
    Write-Host "   ⚠️  Impossible d'exécuter pnpm type-check" -ForegroundColor $WARNING
    Write-Host "      Assurez-vous que pnpm est installé" -ForegroundColor Gray
    $failedChecks++
}

Pop-Location
Write-Host ""

# Check 12: Node modules
Write-Host "1️⃣2️⃣  Vérification des node_modules..." -ForegroundColor $INFO
$nodeModulesPath = Join-Path $PACKAGE_PATH "node_modules"
if (Test-Path $nodeModulesPath) {
    Write-Host "   ✅ node_modules présent" -ForegroundColor $SUCCESS
    $passedChecks++
} else {
    Write-Host "   ⚠️  node_modules manquant" -ForegroundColor $WARNING
    Write-Host "      Exécutez: pnpm install" -ForegroundColor Gray
    $failedChecks++
}
$totalChecks++
Write-Host ""

# ═══════════════════════════════════════════════════════════
# RÉSUMÉ
# ═══════════════════════════════════════════════════════════

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 Résumé de la vérification" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$successRate = [math]::Round(($passedChecks / $totalChecks) * 100, 1)

Write-Host "Total vérifications: $totalChecks" -ForegroundColor White
Write-Host "Réussies: $passedChecks" -ForegroundColor $SUCCESS
Write-Host "Échouées: $failedChecks" -ForegroundColor $ERROR
Write-Host "Taux de réussite: $successRate%" -ForegroundColor $(if ($successRate -ge 90) { $SUCCESS } elseif ($successRate -ge 70) { $WARNING } else { $ERROR })
Write-Host ""

# Statut final
if ($failedChecks -eq 0) {
    Write-Host "✅ Installation complète et fonctionnelle !" -ForegroundColor $SUCCESS
    Write-Host ""
    Write-Host "🚀 Vous pouvez passer à la Phase 8 :" -ForegroundColor $INFO
    Write-Host "   - Créer l'application admin shell" -ForegroundColor White
    Write-Host "   - Configurer le layout avec AdminLayout" -ForegroundColor White
    Write-Host "   - Créer la route dynamique [module]/[[...slug]]" -ForegroundColor White
    Write-Host ""
    $exitCode = 0
} elseif ($failedChecks -le 3) {
    Write-Host "⚠️  Installation majoritairement fonctionnelle" -ForegroundColor $WARNING
    Write-Host ""
    Write-Host "Quelques problèmes mineurs détectés." -ForegroundColor White
    Write-Host "Vérifiez les erreurs ci-dessus et corrigez-les." -ForegroundColor White
    Write-Host ""
    $exitCode = 1
} else {
    Write-Host "❌ Installation incomplète" -ForegroundColor $ERROR
    Write-Host ""
    Write-Host "Plusieurs problèmes détectés." -ForegroundColor White
    Write-Host "Veuillez relancer le script install-admin-shell.ps1" -ForegroundColor White
    Write-Host ""
    $exitCode = 2
}

# Recommandations
if ($failedChecks -gt 0) {
    Write-Host "💡 Recommandations :" -ForegroundColor $INFO
    Write-Host ""
    
    if (-Not (Test-Path (Join-Path $PACKAGE_PATH "node_modules"))) {
        Write-Host "   1. Installer les dépendances :" -ForegroundColor White
        Write-Host "      cd packages/admin-shell && pnpm install" -ForegroundColor Cyan
        Write-Host ""
    }
    
    if ($failedChecks -ge 5) {
        Write-Host "   2. Relancer l'installation complète :" -ForegroundColor White
        Write-Host "      .\install-admin-shell.ps1" -ForegroundColor Cyan
        Write-Host ""
    }
}

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Pause
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

exit $exitCode
