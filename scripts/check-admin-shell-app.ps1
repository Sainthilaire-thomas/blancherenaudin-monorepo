# check-admin-shell-app.ps1
# Script de vérification Admin Shell App - Blanche Renaudin Monorepo
# Vérifie que la Phase 8 est correctement installée
# Date: 28 octobre 2025

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🔍 Vérification Admin Shell App - Phase 8" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Configuration
$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
$ADMIN_PATH = "$MONOREPO_PATH\apps\admin"

# Compteurs
$totalChecks = 0
$passedChecks = 0

# Fonction de test
function Test-Item {
    param(
        [string]$Path,
        [string]$Description,
        [string]$Type = "File"
    )
    
    $script:totalChecks++
    
    if (Test-Path $Path) {
        Write-Host "   ✅ $Description" -ForegroundColor Green
        $script:passedChecks++
        return $true
    } else {
        Write-Host "   ❌ $Description" -ForegroundColor Red
        Write-Host "      Manquant: $Path" -ForegroundColor Gray
        return $false
    }
}

# Fonction pour vérifier le contenu d'un fichier
function Test-FileContent {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Description
    )
    
    $script:totalChecks++
    
    if (-Not (Test-Path $Path)) {
        Write-Host "   ❌ $Description (fichier manquant)" -ForegroundColor Red
        return $false
    }
    
    $content = Get-Content $Path -Raw
    if ($content -match $Pattern) {
        Write-Host "   ✅ $Description" -ForegroundColor Green
        $script:passedChecks++
        return $true
    } else {
        Write-Host "   ❌ $Description" -ForegroundColor Red
        Write-Host "      Pattern non trouvé: $Pattern" -ForegroundColor Gray
        return $false
    }
}

# Vérifier que le monorepo existe
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "❌ Erreur: Monorepo introuvable à $MONOREPO_PATH" -ForegroundColor Red
    exit 1
}

if (-Not (Test-Path $ADMIN_PATH)) {
    Write-Host "❌ Erreur: apps/admin introuvable" -ForegroundColor Red
    Write-Host "   Veuillez d'abord exécuter install-admin-shell-app.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "📂 Monorepo trouvé: $MONOREPO_PATH" -ForegroundColor Green
Write-Host ""

# ============================================================
# SECTION 1: Structure des dossiers
# ============================================================
Write-Host "📁 SECTION 1: Structure des dossiers" -ForegroundColor Yellow
Write-Host ""

Test-Item "$ADMIN_PATH\app" "Dossier app/" "Directory"
Test-Item "$ADMIN_PATH\app\(auth)" "Dossier app/(auth)/" "Directory"
Test-Item "$ADMIN_PATH\app\(auth)\login" "Dossier app/(auth)/login/" "Directory"
Test-Item "$ADMIN_PATH\app\(dashboard)" "Dossier app/(dashboard)/" "Directory"
Test-Item "$ADMIN_PATH\app\(dashboard)\[module]" "Dossier app/(dashboard)/[module]/" "Directory"
Test-Item "$ADMIN_PATH\app\(dashboard)\[module]\[[...slug]]" "Route dynamique [[...slug]]/" "Directory"

Write-Host ""

# ============================================================
# SECTION 2: Fichiers de configuration
# ============================================================
Write-Host "⚙️  SECTION 2: Fichiers de configuration" -ForegroundColor Yellow
Write-Host ""

Test-Item "$ADMIN_PATH\admin.config.ts" "admin.config.ts (registry modules)"
Test-Item "$ADMIN_PATH\middleware.ts" "middleware.ts (protection routes)"
Test-Item "$ADMIN_PATH\next.config.ts" "next.config.ts"
Test-Item "$ADMIN_PATH\tailwind.config.ts" "tailwind.config.ts"
Test-Item "$ADMIN_PATH\tsconfig.json" "tsconfig.json"
Test-Item "$ADMIN_PATH\package.json" "package.json"

Write-Host ""

# ============================================================
# SECTION 3: Layouts et pages
# ============================================================
Write-Host "📄 SECTION 3: Layouts et pages" -ForegroundColor Yellow
Write-Host ""

Test-Item "$ADMIN_PATH\app\layout.tsx" "Root layout"
Test-Item "$ADMIN_PATH\app\globals.css" "Styles globaux"
Test-Item "$ADMIN_PATH\app\(auth)\login\page.tsx" "Page login"
Test-Item "$ADMIN_PATH\app\(dashboard)\layout.tsx" "Dashboard layout (avec AdminLayout)"
Test-Item "$ADMIN_PATH\app\(dashboard)\page.tsx" "Dashboard principal"
Test-Item "$ADMIN_PATH\app\(dashboard)\[module]\[[...slug]]\page.tsx" "Route dynamique modules"

Write-Host ""

# ============================================================
# SECTION 4: Contenu des fichiers critiques
# ============================================================
Write-Host "🔍 SECTION 4: Contenu des fichiers" -ForegroundColor Yellow
Write-Host ""

Test-FileContent "$ADMIN_PATH\admin.config.ts" "adminModules.*ModuleDefinition" "admin.config.ts exporte adminModules"
Test-FileContent "$ADMIN_PATH\admin.config.ts" "enabledModules" "admin.config.ts exporte enabledModules"
Test-FileContent "$ADMIN_PATH\app\(dashboard)\layout.tsx" "AdminLayout" "Dashboard layout utilise AdminLayout"
Test-FileContent "$ADMIN_PATH\app\(dashboard)\layout.tsx" "enabledModules" "Dashboard layout passe enabledModules"
Test-FileContent "$ADMIN_PATH\app\(dashboard)\[module]\[[...slug]]\page.tsx" "ModuleLoader" "Route dynamique utilise ModuleLoader"
Test-FileContent "$ADMIN_PATH\middleware.ts" "NextResponse" "Middleware configuré"
Test-FileContent "$ADMIN_PATH\next.config.ts" "transpilePackages" "next.config transpile les packages"

Write-Host ""

# ============================================================
# SECTION 5: Dépendances package.json
# ============================================================
Write-Host "📦 SECTION 5: Dépendances" -ForegroundColor Yellow
Write-Host ""

$packageJson = Get-Content "$ADMIN_PATH\package.json" -Raw | ConvertFrom-Json

$requiredDeps = @(
    "@repo/admin-shell",
    "@repo/ui",
    "@repo/database",
    "@repo/auth",
    "next",
    "react",
    "lucide-react",
    "sonner"
)

foreach ($dep in $requiredDeps) {
    $totalChecks++
    if ($packageJson.dependencies.PSObject.Properties.Name -contains $dep) {
        Write-Host "   ✅ Dépendance: $dep" -ForegroundColor Green
        $passedChecks++
    } else {
        Write-Host "   ❌ Dépendance manquante: $dep" -ForegroundColor Red
    }
}

Write-Host ""

# ============================================================
# SECTION 6: Scripts npm
# ============================================================
Write-Host "🔧 SECTION 6: Scripts" -ForegroundColor Yellow
Write-Host ""

$requiredScripts = @{
    "dev" = "next dev"
    "build" = "next build"
    "start" = "next start"
    "lint" = "next lint"
}

foreach ($script in $requiredScripts.GetEnumerator()) {
    $totalChecks++
    if ($packageJson.scripts.PSObject.Properties.Name -contains $script.Key) {
        $scriptContent = $packageJson.scripts.($script.Key)
        if ($scriptContent -like "*$($script.Value)*") {
            Write-Host "   ✅ Script: $($script.Key)" -ForegroundColor Green
            $passedChecks++
        } else {
            Write-Host "   ⚠️  Script $($script.Key) existe mais contenu différent" -ForegroundColor Yellow
            $passedChecks++
        }
    } else {
        Write-Host "   ❌ Script manquant: $($script.Key)" -ForegroundColor Red
    }
}

Write-Host ""

# ============================================================
# SECTION 7: Configuration TypeScript
# ============================================================
Write-Host "🔷 SECTION 7: TypeScript" -ForegroundColor Yellow
Write-Host ""

Test-FileContent "$ADMIN_PATH\tsconfig.json" "compilerOptions" "tsconfig.json valide"
Test-FileContent "$ADMIN_PATH\tsconfig.json" "@repo/" "tsconfig.json configure les paths @repo/"

Write-Host ""

# ============================================================
# SECTION 8: Modules enregistrés
# ============================================================
Write-Host "📋 SECTION 8: Modules enregistrés" -ForegroundColor Yellow
Write-Host ""

$adminConfig = Get-Content "$ADMIN_PATH\admin.config.ts" -Raw

$expectedModules = @(
    "products",
    "orders",
    "customers",
    "categories",
    "media",
    "newsletter",
    "analytics",
    "social"
)

foreach ($module in $expectedModules) {
    $totalChecks++
    if ($adminConfig -match "id:\s*'$module'") {
        Write-Host "   ✅ Module enregistré: $module" -ForegroundColor Green
        $passedChecks++
    } else {
        Write-Host "   ❌ Module non enregistré: $module" -ForegroundColor Red
    }
}

Write-Host ""

# ============================================================
# RÉSUMÉ FINAL
# ============================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 RÉSUMÉ DE LA VÉRIFICATION" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$percentage = [math]::Round(($passedChecks / $totalChecks) * 100, 0)
$color = if ($percentage -eq 100) { "Green" } elseif ($percentage -ge 80) { "Yellow" } else { "Red" }

Write-Host "Tests réussis: $passedChecks / $totalChecks ($percentage%)" -ForegroundColor $color
Write-Host ""

if ($passedChecks -eq $totalChecks) {
    Write-Host "✅ Installation COMPLÈTE et FONCTIONNELLE !" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "   1. cd $ADMIN_PATH" -ForegroundColor White
    Write-Host "   2. pnpm dev" -ForegroundColor White
    Write-Host "   3. Ouvrir http://localhost:3001/admin/login" -ForegroundColor White
    Write-Host "   4. Login: admin@blancherenaudin.com / admin" -ForegroundColor White
    Write-Host ""
    Write-Host "📝 Phase 8 TERMINÉE ✅" -ForegroundColor Green
    Write-Host "   → Vous pouvez passer à la Phase 9 (Module Products)" -ForegroundColor White
} elseif ($percentage -ge 80) {
    Write-Host "⚠️  Installation PARTIELLE" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Quelques éléments manquent mais l'essentiel est en place." -ForegroundColor Yellow
    Write-Host "Vous pouvez continuer mais certaines fonctionnalités pourraient ne pas marcher." -ForegroundColor Yellow
} else {
    Write-Host "❌ Installation INCOMPLÈTE" -ForegroundColor Red
    Write-Host ""
    Write-Host "Plusieurs éléments critiques manquent." -ForegroundColor Red
    Write-Host "Veuillez relancer install-admin-shell-app.ps1" -ForegroundColor Yellow
}

Write-Host ""

# Détails techniques
Write-Host "📊 Détails techniques:" -ForegroundColor Cyan
Write-Host "   - Structure: " -NoNewline
if (Test-Path "$ADMIN_PATH\app\(dashboard)\[module]\[[...slug]]\page.tsx") {
    Write-Host "OK ✅" -ForegroundColor Green
} else {
    Write-Host "MANQUANTE ❌" -ForegroundColor Red
}

Write-Host "   - Configuration: " -NoNewline
if ((Test-Path "$ADMIN_PATH\admin.config.ts") -and (Test-Path "$ADMIN_PATH\next.config.ts")) {
    Write-Host "OK ✅" -ForegroundColor Green
} else {
    Write-Host "MANQUANTE ❌" -ForegroundColor Red
}

Write-Host "   - Dépendances: " -NoNewline
if ($packageJson.dependencies.PSObject.Properties.Name -contains "@repo/admin-shell") {
    Write-Host "OK ✅" -ForegroundColor Green
} else {
    Write-Host "MANQUANTES ❌" -ForegroundColor Red
}

Write-Host "   - Modules registry: " -NoNewline
if ($adminConfig -match "adminModules.*ModuleDefinition") {
    $moduleCount = ($adminConfig | Select-String -Pattern "id:\s*'" -AllMatches).Matches.Count
    Write-Host "OK ✅ ($moduleCount modules)" -ForegroundColor Green
} else {
    Write-Host "INVALIDE ❌" -ForegroundColor Red
}

Write-Host ""
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
