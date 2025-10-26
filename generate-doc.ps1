Write-Host 'Generating complete package documentation...' -ForegroundColor Cyan

$markdown = @'
# 📦 Documentation des Packages Migrés
## Monorepo blancherenaudin

*Généré automatiquement le {0}*

---

'@ -f (Get-Date -Format 'dd/MM/yyyy HH:mm')

# =============================================
# FONCTION POUR DOCUMENTER UN PACKAGE
# =============================================
function Get-PackageDoc {
    param($name, $path)
    
    if (-not (Test-Path $path)) {
        return "
## ❌ @repo/$name

**Status:** Package non trouvé

---
"
    }
    
    $doc = "
## 📦 @repo/$name

"
    
    # Lire package.json
    $pkgPath = Join-Path $path 'package.json'
    if (Test-Path $pkgPath) {
        $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
        $doc += "**Version:** `{0}`
" -f $pkg.version
        if ($pkg.description) {
            $doc += "**Description:** {0}
" -f $pkg.description
        }
        $doc += "
"
    }
    
    # Structure des fichiers
    $srcPath = Join-Path $path 'src'
    if (Test-Path $srcPath) {
        $doc += "### 📁 Structure

```"
        $doc += "src/
"
        
        Get-ChildItem -Path $srcPath -Recurse | ForEach-Object {
            $relativePath = $_.FullName.Replace($srcPath + '\', '').Replace('\', '/')
            $depth = ($relativePath.Split('/')).Count - 1
            $indent = '  ' * $depth
            
            if ($_.PSIsContainer) {
                $doc += "$indent├── $($_.Name)/
"
            } else {
                $doc += "$indent├── $($_.Name)
"
            }
        }
        $doc += "```

"
    }
    
    # Exports principaux
    $indexPath = Join-Path $srcPath 'index.ts'
    if (Test-Path $indexPath) {
        $doc += "### 📤 Exports Principaux

```typescript
"
        $exports = Get-Content $indexPath | Where-Object { $_ -match 'export' }
        foreach ($export in $exports) {
            $doc += "$export
"
        }
        $doc += "```

"
    }
    
    # Dépendances
    if (Test-Path $pkgPath) {
        $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
        if ($pkg.dependencies) {
            $doc += "### 📚 Dépendances

"
            $pkg.dependencies.PSObject.Properties | ForEach-Object {
                $doc += "- `{0}`: {1}
" -f $_.Name, $_.Value
            }
            $doc += "
"
        }
    }
    
    $doc += "---
"
    return $doc
}

# =============================================
# DOCUMENTER TOUS LES PACKAGES
# =============================================

$markdown += "
# 🎯 Packages Core
"
$markdown += Get-PackageDoc 'database' 'packages\database'
$markdown += Get-PackageDoc 'auth' 'packages\auth'
$markdown += Get-PackageDoc 'sanity' 'packages\sanity'

$markdown += "
# 🎨 UI & Utils
"
$markdown += Get-PackageDoc 'ui' 'packages\ui'
$markdown += Get-PackageDoc 'utils' 'packages\utils'

$markdown += "
# 🔧 Services
"
$markdown += Get-PackageDoc 'email' 'packages\email'
$markdown += Get-PackageDoc 'analytics' 'packages\analytics'
$markdown += Get-PackageDoc 'shipping' 'packages\shipping'
$markdown += Get-PackageDoc 'newsletter' 'packages\newsletter'

$markdown += "
# ⚙️ Configuration
"
$markdown += Get-PackageDoc 'config' 'packages\config'

# =============================================
# DOCUMENTER STOREFRONT
# =============================================

$markdown += "
---

# 🚀 Application Storefront

"

if (Test-Path 'apps\storefront') {
    $markdown += "## 📊 Statistiques

"
    
    # Routes
    $routeFiles = Get-ChildItem -Path 'apps\storefront\app' -Include 'page.tsx','route.ts','layout.tsx' -Recurse -File
    $markdown += "- **Routes totales:** {0}
" -f $routeFiles.Count
    
    # Components app-specific
    if (Test-Path 'apps\storefront\components') {
        $appComponents = Get-ChildItem -Path 'apps\storefront\components' -Filter '*.tsx' -Recurse -File
        $markdown += "- **Composants app-specific:** {0}
" -f $appComponents.Count
    }
    
    # Stores
    if (Test-Path 'apps\storefront\store') {
        $stores = Get-ChildItem -Path 'apps\storefront\store' -Filter '*.ts' -File
        $markdown += "- **Stores Zustand:** {0}
" -f $stores.Count
        $markdown += "
### 🗄️ Stores

"
        $stores | ForEach-Object {
            $markdown += "- `{0}`
" -f $_.Name
        }
    }
    
    # Routes principales
    $markdown += "
### 🛣️ Routes Principales

"
    $criticalRoutes = @(
        'api/webhooks/stripe',
        'api/checkout',
        'api/products',
        'api/orders',
        'api/admin',
        'product',
        'products',
        'cart',
        'checkout',
        'account'
    )
    
    foreach ($route in $criticalRoutes) {
        $routePath = "apps\storefront\app\$route"
        if (Test-Path $routePath) {
            $markdown += "- ✅ `/{0}`
" -f $route.Replace('\', '/')
        } else {
            $markdown += "- ❌ `/{0}` (manquant)
" -f $route.Replace('\', '/')
        }
    }
}

# =============================================
# RÉSUMÉ
# =============================================

$markdown += "
---

# 📈 Résumé de la Migration

"

$totalPackages = (Get-ChildItem 'packages' -Directory).Count
$markdown += "## Packages

"
$markdown += "- **Total packages:** {0}
" -f $totalPackages

$totalComponents = 0
if (Test-Path 'packages\ui\src\components') {
    $totalComponents = (Get-ChildItem 'packages\ui\src\components' -Filter '*.tsx' -Recurse -File).Count
}
if (Test-Path 'apps\storefront\components') {
    $totalComponents += (Get-ChildItem 'apps\storefront\components' -Filter '*.tsx' -Recurse -File).Count
}
$markdown += "- **Total composants:** {0}
" -f $totalComponents

$markdown += "
## Status Global

"
$markdown += "| Package | Status | Fichiers | Notes |
"
$markdown += "|---------|--------|----------|-------|
"

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
        $markdown += "| @repo/{0} | {1} | {2} | |
" -f $pkg.Name, $status, $fileCount
    } else {
        $markdown += "| @repo/{0} | ❌ Absent | 0 | |
" -f $pkg.Name
    }
}

$markdown += "
---

"
$markdown += "*📝 Cette documentation est générée automatiquement. Pour la mettre à jour, relancez le script `doc-packages.ps1`*
"

# Sauvegarder
$markdown | Out-File -FilePath 'PACKAGES-DOC.md' -Encoding UTF8

Write-Host '✅ Documentation générée: PACKAGES-DOC.md' -ForegroundColor Green
Write-Host "
Ouvrez le fichier pour voir la documentation complète!" -ForegroundColor Cyan
