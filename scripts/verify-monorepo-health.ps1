# verify-monorepo-health.ps1
# Vérification complète du monorepo après Phase 8.5
# Date: 27 octobre 2025

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🔍 Vérification Santé Monorepo - Phase 8.5" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

# Vérifier qu'on est dans le bon dossier
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "❌ Monorepo introuvable" -ForegroundColor Red
    exit 1
}

Set-Location $MONOREPO_PATH

# ============================================================================
# TEST 1: Type-check (déjà validé)
# ============================================================================
Write-Host "📋 TEST 1: Type-check TypeScript" -ForegroundColor Yellow
Write-Host ""

$typeCheckOutput = pnpm type-check 2>&1 | Out-String
$typeCheckSuccess = $LASTEXITCODE -eq 0

if ($typeCheckSuccess) {
    Write-Host "   ✅ Type-check: RÉUSSI" -ForegroundColor Green
    
    # Compter les succès
    if ($typeCheckOutput -match "Tasks:\s+(\d+)\s+successful") {
        $successCount = $Matches[1]
        Write-Host "   📊 $successCount/14 packages validés" -ForegroundColor Green
    }
} else {
    Write-Host "   ❌ Type-check: ÉCHOUÉ" -ForegroundColor Red
    Write-Host $typeCheckOutput -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# TEST 2: Build des packages
# ============================================================================
Write-Host "📋 TEST 2: Build des packages compilables" -ForegroundColor Yellow
Write-Host ""

$buildOutput = pnpm build 2>&1 | Out-String
$buildSuccess = $LASTEXITCODE -eq 0

if ($buildSuccess) {
    Write-Host "   ✅ Build: RÉUSSI" -ForegroundColor Green
} else {
    Write-Host "   ❌ Build: ÉCHOUÉ" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Red
}

Write-Host ""

# ============================================================================
# TEST 3: Lint (vérification code style)
# ============================================================================
Write-Host "📋 TEST 3: Lint (optionnel)" -ForegroundColor Yellow
Write-Host ""

$lintOutput = pnpm lint 2>&1 | Out-String
$lintSuccess = $LASTEXITCODE -eq 0

if ($lintSuccess) {
    Write-Host "   ✅ Lint: RÉUSSI" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Lint: AVERTISSEMENTS (non bloquant)" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================================
# TEST 4: Vérification structure fichiers critiques
# ============================================================================
Write-Host "📋 TEST 4: Fichiers critiques" -ForegroundColor Yellow
Write-Host ""

$criticalFiles = @(
    "tsconfig.base.json",
    "apps/admin/app/(dashboard)/[module]/[[...slug]]/page.tsx",
    "apps/storefront/app/api/admin/product-images/[imageId]/signed-url/route.ts",
    "packages/ui/package.json",
    "apps/admin/package.json",
    "apps/storefront/package.json"
)

$allFilesExist = $true
foreach ($file in $criticalFiles) {
    $fullPath = Join-Path $MONOREPO_PATH $file
    if (Test-Path $fullPath) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $file (MANQUANT)" -ForegroundColor Red
        $allFilesExist = $false
    }
}

Write-Host ""

# ============================================================================
# TEST 5: Vérification versions React
# ============================================================================
Write-Host "📋 TEST 5: Versions React" -ForegroundColor Yellow
Write-Host ""

function Get-ReactVersion {
    param([string]$PackageJsonPath)
    
    if (Test-Path $PackageJsonPath) {
        $content = Get-Content $PackageJsonPath -Raw | ConvertFrom-Json
        $reactVersion = $content.dependencies.react
        return $reactVersion
    }
    return "N/A"
}

$adminReact = Get-ReactVersion "apps/admin/package.json"
$storefrontReact = Get-ReactVersion "apps/storefront/package.json"

Write-Host "   apps/admin: React $adminReact" -ForegroundColor $(if ($adminReact -match "19\.") { "Green" } else { "Red" })
Write-Host "   apps/storefront: React $storefrontReact" -ForegroundColor $(if ($storefrontReact -match "19\.") { "Green" } else { "Red" })

Write-Host ""

# ============================================================================
# TEST 6: Vérification params async (Next.js 15)
# ============================================================================
Write-Host "📋 TEST 6: Conformité Next.js 15 (params async)" -ForegroundColor Yellow
Write-Host ""

$pageTsxPath = "apps/admin/app/(dashboard)/[module]/[[...slug]]/page.tsx"
$routeTsPath = "apps/storefront/app/api/admin/product-images/[imageId]/signed-url/route.ts"

$pageContent = Get-Content $pageTsxPath -Raw
$routeContent = Get-Content $routeTsPath -Raw

$pageHasPromise = $pageContent -match "params:\s*Promise<"
$pageHasAwait = $pageContent -match "await\s+params"
$routeHasPromise = $routeContent -match "params:\s*Promise<"
$routeHasAwait = $routeContent -match "await\s+.*params"

Write-Host "   page.tsx:" -ForegroundColor White
Write-Host "     - params: Promise<...>: $(if ($pageHasPromise) { '✅' } else { '❌' })" -ForegroundColor $(if ($pageHasPromise) { "Green" } else { "Red" })
Write-Host "     - await params: $(if ($pageHasAwait) { '✅' } else { '❌' })" -ForegroundColor $(if ($pageHasAwait) { "Green" } else { "Red" })

Write-Host "   route.ts:" -ForegroundColor White
Write-Host "     - params: Promise<...>: $(if ($routeHasPromise) { '✅' } else { '❌' })" -ForegroundColor $(if ($routeHasPromise) { "Green" } else { "Red" })
Write-Host "     - await params: $(if ($routeHasAwait) { '✅' } else { '❌' })" -ForegroundColor $(if ($routeHasAwait) { "Green" } else { "Red" })

Write-Host ""

# ============================================================================
# RÉSUMÉ FINAL
# ============================================================================
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 RÉSUMÉ GLOBAL" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$allTestsPassed = $typeCheckSuccess -and $buildSuccess -and $allFilesExist -and 
                  $pageHasPromise -and $pageHasAwait -and 
                  $routeHasPromise -and $routeHasAwait

if ($allTestsPassed) {
    Write-Host "🎉 TOUS LES TESTS RÉUSSIS !" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Phase 8.5 - Migration React 19: COMPLÈTE" -ForegroundColor Green
    Write-Host "✅ TypeScript: Tous les packages validés" -ForegroundColor Green
    Write-Host "✅ Build: Compilation réussie" -ForegroundColor Green
    Write-Host "✅ Next.js 15: Conformité params async" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 PRÊT POUR LA PHASE 9 (Migration Products)" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host "⚠️  QUELQUES PROBLÈMES DÉTECTÉS" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not $typeCheckSuccess) {
        Write-Host "❌ Type-check en échec" -ForegroundColor Red
    }
    if (-not $buildSuccess) {
        Write-Host "❌ Build en échec" -ForegroundColor Red
    }
    if (-not $allFilesExist) {
        Write-Host "❌ Fichiers critiques manquants" -ForegroundColor Red
    }
    if (-not ($pageHasPromise -and $pageHasAwait)) {
        Write-Host "❌ page.tsx non conforme Next.js 15" -ForegroundColor Red
    }
    if (-not ($routeHasPromise -and $routeHasAwait)) {
        Write-Host "❌ route.ts non conforme Next.js 15" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "📖 Consulte les détails ci-dessus pour corriger" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Pause
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
