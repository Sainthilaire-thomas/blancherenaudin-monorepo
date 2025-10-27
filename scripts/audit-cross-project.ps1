Write-Host '============================================' -ForegroundColor Cyan
Write-Host '   AUDIT CROISÉ: site_v1_next vs monorepo' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan

# Chemins des projets
$originalPath = '..\site_v1_next'
$monorepoPath = '.'

# Vérifier que le projet original existe
if (-not (Test-Path $originalPath)) {
    Write-Host 'ERROR: Cannot find site_v1_next project!' -ForegroundColor Red
    Write-Host 'Please run this from blancherenaudin-monorepo directory' -ForegroundColor Yellow
    Write-Host 'And ensure site_v1_next is in the parent directory' -ForegroundColor Yellow
    exit
}

Write-Host "
Original project found at: $originalPath
" -ForegroundColor Green

# =============================================
# 1. COMPARER LES FICHIERS src/lib
# =============================================
Write-Host '[1/6] Comparing src/lib files...' -ForegroundColor Yellow

$originalLibFiles = Get-ChildItem -Path "$originalPath\src\lib" -File -Recurse -ErrorAction SilentlyContinue | 
    Select-Object @{Name='RelativePath';Expression={$_.FullName.Replace((Resolve-Path "$originalPath\src\lib").Path + '\', '')}}

$migratedLibFiles = @()
if (Test-Path 'packages\utils\src') {
    $migratedLibFiles += Get-ChildItem -Path 'packages\utils\src' -File -Recurse | 
        Select-Object @{Name='Name';Expression={$_.Name}}
}
if (Test-Path 'packages\database\src') {
    $migratedLibFiles += Get-ChildItem -Path 'packages\database\src' -File -Recurse | 
        Select-Object @{Name='Name';Expression={$_.Name}}
}
if (Test-Path 'packages\auth\src') {
    $migratedLibFiles += Get-ChildItem -Path 'packages\auth\src' -File -Recurse | 
        Select-Object @{Name='Name';Expression={$_.Name}}
}

Write-Host "
  Original src/lib files:" -ForegroundColor Cyan
foreach ($file in $originalLibFiles) {
    $basename = [System.IO.Path]::GetFileName($file.RelativePath)
    $found = $migratedLibFiles | Where-Object { $_.Name -eq $basename }
    if ($found) {
        Write-Host "    OK: $($file.RelativePath)" -ForegroundColor Green
    } else {
        Write-Host "    MISSING: $($file.RelativePath)" -ForegroundColor Red
    }
}

# =============================================
# 2. COMPARER LES COMPOSANTS
# =============================================
Write-Host "
[2/6] Comparing components..." -ForegroundColor Yellow

$originalComponents = Get-ChildItem -Path "$originalPath\src\components" -File -Recurse -Filter '*.tsx' -ErrorAction SilentlyContinue |
    Select-Object Name

$monorepoComponents = Get-ChildItem -Path 'packages\ui\src\components' -File -Recurse -Filter '*.tsx' -ErrorAction SilentlyContinue |
    Select-Object Name

Write-Host "  Original: $($originalComponents.Count) components" -ForegroundColor Cyan
Write-Host "  Monorepo: $($monorepoComponents.Count) components" -ForegroundColor Cyan

$missingComponents = $originalComponents | Where-Object { 
    $name = $_.Name
    -not ($monorepoComponents | Where-Object { $_.Name -eq $name })
}

if ($missingComponents.Count -gt 0) {
    Write-Host "
  MISSING $($missingComponents.Count) components:" -ForegroundColor Red
    foreach ($comp in $missingComponents | Select-Object -First 20) {
        Write-Host "    - $($comp.Name)" -ForegroundColor Gray
    }
    if ($missingComponents.Count -gt 20) {
        Write-Host "    ... and $($missingComponents.Count - 20) more" -ForegroundColor Gray
    }
} else {
    Write-Host '  OK: All components migrated' -ForegroundColor Green
}

# =============================================
# 3. COMPARER LES ROUTES APP
# =============================================
Write-Host "
[3/6] Comparing app routes..." -ForegroundColor Yellow

$originalRoutes = Get-ChildItem -Path "$originalPath\src\app" -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '^[\[\(].*[\]\)]$' } |
    Select-Object @{Name='RelativePath';Expression={$_.FullName.Replace((Resolve-Path "$originalPath\src\app").Path, '').TrimStart('\')}}

$monorepoRoutes = Get-ChildItem -Path 'apps\storefront\app' -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '^[\[\(].*[\]\)]$' } |
    Select-Object @{Name='RelativePath';Expression={$_.FullName.Replace((Resolve-Path 'apps\storefront\app').Path, '').TrimStart('\')}}

Write-Host "  Original: $($originalRoutes.Count) route directories" -ForegroundColor Cyan
Write-Host "  Monorepo: $($monorepoRoutes.Count) route directories" -ForegroundColor Cyan

$missingRoutes = $originalRoutes | Where-Object {
    $path = $_.RelativePath
    -not ($monorepoRoutes | Where-Object { $_.RelativePath -eq $path })
}

if ($missingRoutes.Count -gt 0) {
    Write-Host "
  MISSING $($missingRoutes.Count) routes:" -ForegroundColor Red
    foreach ($route in $missingRoutes | Select-Object -First 15) {
        Write-Host "    - /$($route.RelativePath)" -ForegroundColor Gray
    }
    if ($missingRoutes.Count -gt 15) {
        Write-Host "    ... and $($missingRoutes.Count - 15) more" -ForegroundColor Gray
    }
} else {
    Write-Host '  OK: All routes migrated' -ForegroundColor Green
}

# =============================================
# 4. COMPARER LES STORES ZUSTAND
# =============================================
Write-Host "
[4/6] Comparing Zustand stores..." -ForegroundColor Yellow

$originalStores = Get-ChildItem -Path "$originalPath\src\store" -File -Filter '*.ts' -ErrorAction SilentlyContinue |
    Select-Object Name

$monorepoStores = Get-ChildItem -Path 'apps\storefront\store' -File -Filter '*.ts' -ErrorAction SilentlyContinue |
    Select-Object Name

if ($originalStores) {
    Write-Host "  Original: $($originalStores.Count) stores" -ForegroundColor Cyan
    Write-Host "  Monorepo: $($monorepoStores.Count) stores" -ForegroundColor Cyan
    
    foreach ($store in $originalStores) {
        if ($monorepoStores | Where-Object { $_.Name -eq $store.Name }) {
            Write-Host "    OK: $($store.Name)" -ForegroundColor Green
        } else {
            Write-Host "    MISSING: $($store.Name)" -ForegroundColor Red
        }
    }
} else {
    Write-Host '  No stores found in original project' -ForegroundColor Gray
}

# =============================================
# 5. COMPARER LES HOOKS
# =============================================
Write-Host "
[5/6] Comparing custom hooks..." -ForegroundColor Yellow

$originalHooks = Get-ChildItem -Path "$originalPath\src\hooks" -File -Filter '*.ts' -ErrorAction SilentlyContinue |
    Select-Object Name

$monorepoHooks = Get-ChildItem -Path 'packages\ui\src\hooks' -File -Filter '*.ts' -ErrorAction SilentlyContinue |
    Select-Object Name

if ($originalHooks) {
    Write-Host "  Original: $($originalHooks.Count) hooks" -ForegroundColor Cyan
    Write-Host "  Monorepo: $($monorepoHooks.Count) hooks" -ForegroundColor Cyan
    
    foreach ($hook in $originalHooks) {
        if ($monorepoHooks | Where-Object { $_.Name -eq $hook.Name }) {
            Write-Host "    OK: $($hook.Name)" -ForegroundColor Green
        } else {
            Write-Host "    MISSING: $($hook.Name)" -ForegroundColor Red
        }
    }
} else {
    Write-Host '  No hooks found in original project' -ForegroundColor Gray
}

# =============================================
# 6. VÉRIFIER LES PACKAGES CRITIQUES
# =============================================
Write-Host "
[6/6] Checking critical package files..." -ForegroundColor Yellow

$criticalFiles = @{
    'supabase-server.ts' = @('packages\database\src', "$originalPath\src\lib")
    'supabase-browser.ts' = @('packages\database\src', "$originalPath\src\lib")
    'supabase-admin.ts' = @('packages\database\src', "$originalPath\src\lib")
    'sanity.client.ts' = @('packages\sanity\src', "$originalPath\src\lib")
    'queries.ts' = @('packages\sanity\src', "$originalPath\src\lib")
    'stripe.ts' = @('apps\storefront\lib', "$originalPath\src\lib")
}

foreach ($file in $criticalFiles.Keys) {
    $targetPath = $criticalFiles[$file][0]
    $sourcePath = $criticalFiles[$file][1]
    
    $existsInTarget = Test-Path (Join-Path $targetPath $file)
    $existsInSource = Test-Path (Join-Path $sourcePath $file)
    
    if ($existsInSource -and $existsInTarget) {
        Write-Host "  OK: $file" -ForegroundColor Green
    } elseif ($existsInSource -and -not $existsInTarget) {
        Write-Host "  MISSING: $file (exists in source, not in target)" -ForegroundColor Red
    } elseif (-not $existsInSource) {
        Write-Host "  SKIP: $file (not in original project)" -ForegroundColor Gray
    }
}

Write-Host "
============================================" -ForegroundColor Cyan
Write-Host '   AUDIT CROISÉ TERMINÉ' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan
