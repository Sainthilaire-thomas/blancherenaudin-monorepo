Write-Host '==========================================' -ForegroundColor Cyan
Write-Host '   AUDIT COMPLET DE LA MIGRATION' -ForegroundColor Cyan
Write-Host '==========================================' -ForegroundColor Cyan

# 1. VÉRIFIER LA STRUCTURE ORIGINALE
Write-Host "
[1/5] Checking original structure..." -ForegroundColor Yellow
$hasOriginalSrc = Test-Path 'src'
if ($hasOriginalSrc) {
    Write-Host '  WARNING: Original src/ directory still exists!' -ForegroundColor Red
    $srcFiles = Get-ChildItem -Path 'src' -Recurse -File | Measure-Object
    Write-Host "  Contains $($srcFiles.Count) files" -ForegroundColor Red
} else {
    Write-Host '  OK: No original src/ directory' -ForegroundColor Green
}

# 2. VÉRIFIER LES IMPORTS @/ DANS STOREFRONT
Write-Host "
[2/5] Checking @/ imports in storefront..." -ForegroundColor Yellow
$atSlashImports = Get-ChildItem -Path 'apps/storefront' -Include '*.ts','*.tsx' -Recurse -File | 
    Select-String -Pattern 'from [''"]@/(?!.*node_modules)' | 
    Group-Object Path | 
    Select-Object Name, Count

if ($atSlashImports) {
    Write-Host "  FOUND $($atSlashImports.Count) files with @/ imports:" -ForegroundColor Yellow
    foreach ($import in $atSlashImports | Select-Object -First 10) {
        $relativePath = $import.Name.Replace((Get-Location).Path + '\', '')
        Write-Host "    - $relativePath ($($import.Count) imports)" -ForegroundColor Gray
    }
    if ($atSlashImports.Count -gt 10) {
        Write-Host "    ... and $($atSlashImports.Count - 10) more files" -ForegroundColor Gray
    }
} else {
    Write-Host '  OK: No @/ imports found' -ForegroundColor Green
}

# 3. VÉRIFIER LES FICHIERS MANQUANTS DANS PACKAGES
Write-Host "
[3/5] Checking for missing package files..." -ForegroundColor Yellow

$expectedPackages = @{
    'ui' = @('components', 'hooks', 'lib')
    'utils' = @('formatters.ts', 'validators.ts', 'images.ts')
    'database' = @('client.ts', 'types.ts')
    'sanity' = @('client.ts', 'queries.ts')
    'auth' = @('client.ts')
}

foreach ($pkg in $expectedPackages.Keys) {
    $pkgPath = "packages/$pkg/src"
    if (Test-Path $pkgPath) {
        Write-Host "  Checking @repo/$pkg..." -ForegroundColor Cyan
        foreach ($item in $expectedPackages[$pkg]) {
            $itemPath = Join-Path $pkgPath $item
            if (Test-Path $itemPath) {
                Write-Host "    OK: $item" -ForegroundColor Green
            } else {
                Write-Host "    MISSING: $item" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "  ERROR: Package $pkg/src does not exist!" -ForegroundColor Red
    }
}

# 4. VÉRIFIER LES DÉPENDANCES DE STOREFRONT
Write-Host "
[4/5] Checking storefront dependencies..." -ForegroundColor Yellow
$storefrontPkg = Get-Content 'apps/storefront/package.json' -Raw | ConvertFrom-Json
$repoDeps = $storefrontPkg.dependencies.PSObject.Properties | Where-Object { $_.Name -like '@repo/*' }

Write-Host "  Found $($repoDeps.Count) @repo/* dependencies:" -ForegroundColor Cyan
foreach ($dep in $repoDeps) {
    $pkgName = $dep.Name -replace '@repo/', ''
    $pkgExists = Test-Path "packages/$pkgName"
    if ($pkgExists) {
        Write-Host "    OK: $($dep.Name)" -ForegroundColor Green
    } else {
        Write-Host "    ERROR: $($dep.Name) package not found!" -ForegroundColor Red
    }
}

# 5. VÉRIFIER LES ROUTES MANQUANTES
Write-Host "
[5/5] Checking for migrated routes..." -ForegroundColor Yellow
$storefrontRoutes = Get-ChildItem -Path 'apps/storefront/app' -Recurse -Include 'page.tsx','route.ts','layout.tsx' -File
Write-Host "  Found $($storefrontRoutes.Count) route files in storefront" -ForegroundColor Cyan

# Vérifier les routes API importantes
$criticalApiRoutes = @(
    'api/webhooks/stripe',
    'api/checkout',
    'api/products',
    'api/admin'
)

foreach ($route in $criticalApiRoutes) {
    $routePath = "apps/storefront/app/$route"
    if (Test-Path $routePath) {
        Write-Host "    OK: /$route" -ForegroundColor Green
    } else {
        Write-Host "    MISSING: /$route" -ForegroundColor Red
    }
}

Write-Host "
==========================================" -ForegroundColor Cyan
Write-Host '   AUDIT COMPLETE' -ForegroundColor Cyan
Write-Host '==========================================' -ForegroundColor Cyan
