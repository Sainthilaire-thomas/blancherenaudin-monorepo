# generate-packages-doc.ps1
# Génère une documentation complète des packages du monorepo

Write-Host "Generating package documentation..." -ForegroundColor Cyan

$markdown = "# 📦 Documentation des Packages Migrés`n"
$markdown += "## Monorepo blancherenaudin`n`n"
$markdown += "*Généré automatiquement le $(Get-Date -Format 'dd/MM/yyyy HH:mm')*`n`n"
$markdown += "---`n`n"

# FONCTION POUR DOCUMENTER UN PACKAGE
function Get-PackageDoc {
    param($name, $path)
    
    if (-not (Test-Path $path)) {
        return "`n## ❌ @repo/$name`n`n**Status:** Package non trouvé`n`n---`n"
    }
    
    $doc = "`n## 📦 @repo/$name`n`n"
    
    # Lire package.json
    $pkgPath = Join-Path $path 'package.json'
    if (Test-Path $pkgPath) {
        $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
        $doc += "**Version:** $($pkg.version)`n"
        if ($pkg.description) {
            $doc += "**Description:** $($pkg.description)`n"
        }
        $doc += "`n"
    }
    
    # Structure des fichiers
    $srcPath = Join-Path $path 'src'
    if (Test-Path $srcPath) {
        $doc += "### 📁 Structure`n`n"
        $files = Get-ChildItem -Path $srcPath -Recurse | Sort-Object FullName
        $doc += "``````text`n"
        $doc += "src/`n"
        foreach ($file in $files) {
            $relativePath = $file.FullName.Replace($srcPath + '\', '').Replace('\', '/')
            $depth = ($relativePath.Split('/')).Count - 1
            $indent = '  ' * $depth
            if ($file.PSIsContainer) {
                $doc += "$indent- $($file.Name)/`n"
            } else {
                $doc += "$indent- $($file.Name)`n"
            }
        }
        $doc += "``````n`n"
    }
    
    # Exports principaux
    $indexPath = Join-Path $srcPath 'index.ts'
    if (Test-Path $indexPath) {
        $doc += "### 📤 Exports`n`n"
        $exports = Get-Content $indexPath | Where-Object { $_ -match 'export' }
        if ($exports) {
            $doc += "``````typescript`n"
            foreach ($export in $exports) {
                $doc += "$export`n"
            }
            $doc += "``````n`n"
        }
    }
    
    # Dépendances
    if (Test-Path $pkgPath) {
        $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
        if ($pkg.dependencies) {
            $doc += "### 📚 Dépendances`n`n"
            $pkg.dependencies.PSObject.Properties | ForEach-Object {
                $doc += "- **$($_.Name):** $($_.Value)`n"
            }
            $doc += "`n"
        }
    }
    
    $doc += "---`n"
    return $doc
}

# DOCUMENTER TOUS LES PACKAGES
$markdown += "`n# 🎯 Packages Core`n"
$markdown += Get-PackageDoc 'database' 'packages\database'
$markdown += Get-PackageDoc 'auth' 'packages\auth'
$markdown += Get-PackageDoc 'sanity' 'packages\sanity'

$markdown += "`n# 🎨 UI & Utils`n"
$markdown += Get-PackageDoc 'ui' 'packages\ui'
$markdown += Get-PackageDoc 'utils' 'packages\utils'

$markdown += "`n# 🔧 Services`n"
$markdown += Get-PackageDoc 'email' 'packages\email'
$markdown += Get-PackageDoc 'analytics' 'packages\analytics'
$markdown += Get-PackageDoc 'shipping' 'packages\shipping'
$markdown += Get-PackageDoc 'newsletter' 'packages\newsletter'

$markdown += "`n# ⚙️ Configuration`n"
$markdown += Get-PackageDoc 'config' 'packages\config'

# DOCUMENTER STOREFRONT
$markdown += "`n---`n`n# 🚀 Application Storefront`n`n"

if (Test-Path 'apps\storefront') {
    $markdown += "## 📊 Statistiques`n`n"
    
    # Routes
    $routeFiles = Get-ChildItem -Path 'apps\storefront\app' -Include 'page.tsx','route.ts','layout.tsx' -Recurse -File
    $markdown += "- **Routes totales:** $($routeFiles.Count)`n"
    
    # Components
    if (Test-Path 'apps\storefront\components') {
        $appComponents = Get-ChildItem -Path 'apps\storefront\components' -Filter '*.tsx' -Recurse -File
        $markdown += "- **Composants app-specific:** $($appComponents.Count)`n"
    }
    
    # Stores
    if (Test-Path 'apps\storefront\store') {
        $stores = Get-ChildItem -Path 'apps\storefront\store' -Filter '*.ts' -File
        $markdown += "- **Stores Zustand:** $($stores.Count)`n`n"
        $markdown += "### 🗄️ Stores`n`n"
        $stores | ForEach-Object {
            $markdown += "- $($_.Name)`n"
        }
    }
}

# RÉSUMÉ
$markdown += "`n---`n`n# 📈 Résumé de la Migration`n`n"

$totalPackages = (Get-ChildItem 'packages' -Directory).Count
$markdown += "## Packages`n`n"
$markdown += "- **Total packages:** $totalPackages`n"

$totalComponents = 0
if (Test-Path 'packages\ui\src\components') {
    $totalComponents = (Get-ChildItem 'packages\ui\src\components' -Filter '*.tsx' -Recurse -File).Count
}
if (Test-Path 'apps\storefront\components') {
    $totalComponents += (Get-ChildItem 'apps\storefront\components' -Filter '*.tsx' -Recurse -File).Count
}
$markdown += "- **Total composants:** $totalComponents`n`n"

$markdown += "## Status Global`n`n"
$markdown += "| Package | Status | Fichiers | Notes |`n"
$markdown += "|---------|--------|----------|-------|`n"

$packages = @(
    @{Name='database'; Path='packages\database'},
    @{Name='auth'; Path='packages\auth'},
    @{Name='sanity'; Path='packages\sanity'},
    @{Name='ui'; Path='packages\ui'},
    @{Name='utils'; Path='packages\utils'},
    @{Name='email'; Path='packages\email'},
    @{Name='analytics'; Path='packages\analytics'},
    @{Name='shipping'; Path='packages\shipping'},
    @{Name='newsletter'; Path='packages\newsletter'}
)

foreach ($pkg in $packages) {
    if (Test-Path $pkg.Path) {
        $fileCount = (Get-ChildItem (Join-Path $pkg.Path 'src') -File -Recurse -ErrorAction SilentlyContinue).Count
        $status = if ($fileCount -gt 0) { '✅ Migré' } else { '⚠️ Vide' }
        $markdown += "| @repo/$($pkg.Name) | $status | $fileCount | |`n"
    } else {
        $markdown += "| @repo/$($pkg.Name) | ❌ Absent | 0 | |`n"
    }
}

$markdown += "`n---`n`n"
$markdown += "*📝 Documentation générée automatiquement. Relancez ``npm run doc`` pour mettre à jour.*`n"

# Sauvegarder
$markdown | Out-File -FilePath 'docs\PACKAGES.md' -Encoding UTF8 -Force

Write-Host "✅ Documentation générée: docs/PACKAGES.md" -ForegroundColor Green
