Write-Host 'Migration des fichiers manquants depuis site_v1_next...' -ForegroundColor Cyan

$source = '..\site_v1_next\src\lib'
$copied = 0
$errors = 0

# Vérifier que le projet source existe
if (-not (Test-Path $source)) {
    Write-Host '❌ Projet source site_v1_next non trouvé!' -ForegroundColor Red
    exit 1
}

# =============================================
# 1. NEWSLETTER (validation + utils)
# =============================================
Write-Host "
[Newsletter]" -ForegroundColor Yellow

if (Test-Path "$source\newsletter\validation.ts") {
    Copy-Item "$source\newsletter\validation.ts" 'packages\newsletter\src\validation.ts' -Force
    Write-Host '  ✅ validation.ts' -ForegroundColor Green
    $copied++
}

if (Test-Path "$source\newsletter\utils.ts") {
    Copy-Item "$source\newsletter\utils.ts" 'packages\newsletter\src\utils.ts' -Force
    Write-Host '  ✅ utils.ts' -ForegroundColor Green
    $copied++
}

# =============================================
# 2. STOCK (decrement-stock)
# =============================================
Write-Host "
[Stock Management]" -ForegroundColor Yellow

if (Test-Path "$source\stock\decrement-stock.ts") {
    New-Item -ItemType Directory -Path 'packages\database\src\stock' -Force | Out-Null
    Copy-Item "$source\stock\decrement-stock.ts" 'packages\database\src\stock\decrement-stock.ts' -Force
    
    # Corriger les imports dans le fichier copié
    $content = Get-Content 'packages\database\src\stock\decrement-stock.ts' -Raw
    $content = $content -replace "from '@/lib/supabase-admin'", "from '../client-admin'"
    [System.IO.File]::WriteAllText('packages\database\src\stock\decrement-stock.ts', $content, [System.Text.Encoding]::UTF8)
    
    Write-Host '  ✅ decrement-stock.ts (imports corrigés)' -ForegroundColor Green
    $copied++
}

# =============================================
# 3. TYPES (types.ts)
# =============================================
Write-Host "
[Types]" -ForegroundColor Yellow

if (Test-Path "$source\types.ts") {
    Copy-Item "$source\types.ts" 'packages\database\src\types.ts' -Force
    
    # Corriger les imports dans le fichier copié
    $content = Get-Content 'packages\database\src\types.ts' -Raw
    $content = $content -replace "from './database.types'", "from './types'"
    [System.IO.File]::WriteAllText('packages\database\src\types.ts', $content, [System.Text.Encoding]::UTF8)
    
    Write-Host '  ✅ types.ts (imports corrigés)' -ForegroundColor Green
    $copied++
}

# =============================================
# 4. SERVICES (customerService)
# =============================================
Write-Host "
[Services]" -ForegroundColor Yellow

if (Test-Path "$source\services\customerService.ts") {
    New-Item -ItemType Directory -Path 'packages\utils\src\services' -Force | Out-Null
    Copy-Item "$source\services\customerService.ts" 'packages\utils\src\services\customerService.ts' -Force
    
    # Corriger les imports
    $content = Get-Content 'packages\utils\src\services\customerService.ts' -Raw
    $content = $content -replace "from '@/lib/supabase-admin'", "from '@repo/database'"
    [System.IO.File]::WriteAllText('packages\utils\src\services\customerService.ts', $content, [System.Text.Encoding]::UTF8)
    
    Write-Host '  ✅ customerService.ts (imports corrigés)' -ForegroundColor Green
    $copied++
}

# =============================================
# 5. VALIDATION (adminCustomers)
# =============================================
Write-Host "
[Validation]" -ForegroundColor Yellow

if (Test-Path "$source\validation\adminCustomers.ts") {
    New-Item -ItemType Directory -Path 'packages\utils\src\validation' -Force | Out-Null
    Copy-Item "$source\validation\adminCustomers.ts" 'packages\utils\src\validation\adminCustomers.ts' -Force
    Write-Host '  ✅ adminCustomers.ts' -ForegroundColor Green
    $copied++
}

# =============================================
# 6. METTRE À JOUR LES EXPORTS
# =============================================
Write-Host "
[Updating exports]" -ForegroundColor Yellow

# Newsletter
Add-Content 'packages\newsletter\src\index.ts' "
export * from './validation'"
Add-Content 'packages\newsletter\src\index.ts' "
export * from './utils'"

# Database
Add-Content 'packages\database\src\index.ts' "
export * from './types'"
Add-Content 'packages\database\src\index.ts' "
export * from './stock/decrement-stock'"

# Utils
Add-Content 'packages\utils\src\index.ts' "
export * from './services/customerService'"
Add-Content 'packages\utils\src\index.ts' "
export * from './validation/adminCustomers'"

Write-Host '  ✅ Exports mis à jour' -ForegroundColor Green

# =============================================
# RÉSUMÉ
# =============================================
Write-Host "
============================================" -ForegroundColor Cyan
Write-Host "  Migration terminée!" -ForegroundColor Green
Write-Host "  Fichiers copiés: $copied" -ForegroundColor Yellow
Write-Host "  Erreurs: $errors" -ForegroundColor Yellow
Write-Host '============================================' -ForegroundColor Cyan
