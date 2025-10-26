Write-Host '============================================' -ForegroundColor Cyan
Write-Host '   DOCUMENTATION DES PACKAGES MIGRÉS' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan

# =============================================
# FONCTION HELPER
# =============================================
function Show-PackageStructure {
    param($packageName, $path)
    
    Write-Host "
[📦 @repo/$packageName]" -ForegroundColor Yellow
    Write-Host "Path: $path
" -ForegroundColor Gray
    
    if (-not (Test-Path $path)) {
        Write-Host "  ❌ Package does not exist!
" -ForegroundColor Red
        return
    }
    
    # Lire le package.json
    $pkgJsonPath = Join-Path $path 'package.json'
    if (Test-Path $pkgJsonPath) {
        $pkg = Get-Content $pkgJsonPath -Raw | ConvertFrom-Json
        Write-Host "  Version: $($pkg.version)" -ForegroundColor Cyan
        if ($pkg.description) {
            Write-Host "  Description: $($pkg.description)" -ForegroundColor Cyan
        }
    }
    
    # Afficher la structure
    Write-Host "
  Structure:" -ForegroundColor Cyan
    $srcPath = Join-Path $path 'src'
    if (Test-Path $srcPath) {
        Get-ChildItem -Path $srcPath -Recurse | ForEach-Object {
            $indent = '  ' * ($_.FullName.Split('\').Count - $srcPath.Split('\').Count)
            if ($_.PSIsContainer) {
                Write-Host "$indent📁 $($_.Name)/" -ForegroundColor Blue
            } else {
                $icon = if ($_.Extension -eq '.ts') { '📘' } 
                        elseif ($_.Extension -eq '.tsx') { '⚛️' }
                        elseif ($_.Extension -eq '.json') { '📋' }
                        else { '📄' }
                Write-Host "$indent$icon $($_.Name)" -ForegroundColor White
            }
        }
    }
    
    # Afficher les exports principaux
    $indexPath = Join-Path $srcPath 'index.ts'
    if (Test-Path $indexPath) {
        Write-Host "
  Exports (from index.ts):" -ForegroundColor Cyan
        Get-Content $indexPath | Where-Object { $_ -match 'export' } | ForEach-Object {
            Write-Host "    $_" -ForegroundColor Gray
        }
    }
    
    Write-Host "
" -ForegroundColor Gray
    Write-Host ('─' * 80) -ForegroundColor DarkGray
}

# =============================================
# DOCUMENTER CHAQUE PACKAGE
# =============================================

Show-PackageStructure 'database' 'packages\database'
Show-PackageStructure 'auth' 'packages\auth'
Show-PackageStructure 'sanity' 'packages\sanity'
Show-PackageStructure 'ui' 'packages\ui'
Show-PackageStructure 'utils' 'packages\utils'
Show-PackageStructure 'email' 'packages\email'
Show-PackageStructure 'analytics' 'packages\analytics'
Show-PackageStructure 'shipping' 'packages\shipping'
Show-PackageStructure 'newsletter' 'packages\newsletter'

# =============================================
# APPS
# =============================================
Write-Host "

[🚀 APPS]" -ForegroundColor Magenta
Write-Host ('─' * 80) -ForegroundColor DarkGray

Write-Host "
[storefront]" -ForegroundColor Yellow
Write-Host "  Routes: " -NoNewline -ForegroundColor Cyan
$routeFiles = Get-ChildItem -Path 'apps\storefront\app' -Include 'page.tsx','route.ts','layout.tsx' -Recurse -File
Write-Host $routeFiles.Count -ForegroundColor White

Write-Host "  Components (app-specific): " -NoNewline -ForegroundColor Cyan
if (Test-Path 'apps\storefront\components') {
    $appComponents = Get-ChildItem -Path 'apps\storefront\components' -Filter '*.tsx' -Recurse -File
    Write-Host $appComponents.Count -ForegroundColor White
} else {
    Write-Host '0' -ForegroundColor Gray
}

Write-Host "  Stores: " -NoNewline -ForegroundColor Cyan
if (Test-Path 'apps\storefront\store') {
    $stores = Get-ChildItem -Path 'apps\storefront\store' -Filter '*.ts' -File
    Write-Host $stores.Count -ForegroundColor White
} else {
    Write-Host '0' -ForegroundColor Gray
}

Write-Host "
============================================" -ForegroundColor Cyan
Write-Host '   DOCUMENTATION GÉNÉRÉE' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan
