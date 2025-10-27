# Script PowerShell - État de la migration Monorepo Blanche Renaudin
# Usage: .\explore-migration-status.ps1 -ProjectRoot "C:\path\to\project"

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = "."
)

Write-Host "`n🔍 ANALYSE DE LA MIGRATION MONOREPO" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Gray

# Fonction pour compter les fichiers dans un dossier
function Count-Files {
    param([string]$Path, [string]$Pattern = "*")
    if (Test-Path $Path) {
        return (Get-ChildItem -Path $Path -Filter $Pattern -Recurse -File -ErrorAction SilentlyContinue).Count
    }
    return 0
}

# Fonction pour lister les routes API
function Get-ApiRoutes {
    param([string]$AppPath)
    
    $apiPath = Join-Path $AppPath "app\api"
    if (-not (Test-Path $apiPath)) {
        return @()
    }
    
    $routes = Get-ChildItem -Path $apiPath -Filter "route.ts*" -Recurse -File -ErrorAction SilentlyContinue
    return $routes | ForEach-Object {
        $relativePath = $_.FullName.Replace($apiPath, "").Replace("\route.ts", "").Replace("\route.tsx", "")
        $relativePath = $relativePath.TrimStart("\")
        "/api/$relativePath"
    }
}

# Fonction pour vérifier l'existence d'un dossier
function Test-ModuleExists {
    param([string]$Path)
    if (Test-Path $Path) {
        Write-Host "  ✅ Existe" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ❌ Manquant" -ForegroundColor Red
        return $false
    }
}

Write-Host "`n📦 PACKAGES" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

$packages = @(
    "config",
    "database", 
    "ui",
    "utils",
    "auth",
    "email",
    "sanity",
    "shipping",
    "analytics",
    "newsletter"
)

$existingPackages = 0
foreach ($pkg in $packages) {
    $pkgPath = Join-Path $ProjectRoot "packages\$pkg"
    Write-Host "`n📁 @repo/$pkg" -NoNewline
    if (Test-ModuleExists $pkgPath) {
        $existingPackages++
        
        # Compter les fichiers pour certains packages
        if ($pkg -eq "ui") {
            $componentCount = Count-Files -Path (Join-Path $pkgPath "src") -Pattern "*.tsx"
            Write-Host "     → $componentCount composants" -ForegroundColor Cyan
        }
        elseif ($pkg -eq "email") {
            $templateCount = Count-Files -Path (Join-Path $pkgPath "templates") -Pattern "*.tsx"
            Write-Host "     → $templateCount templates" -ForegroundColor Cyan
        }
    }
}

Write-Host "`n`n🏪 APPLICATIONS" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

# Vérifier Storefront
Write-Host "`n🛒 apps/storefront" -NoNewline
$storefrontPath = Join-Path $ProjectRoot "apps\storefront"
$storefrontExists = Test-ModuleExists $storefrontPath

if ($storefrontExists) {
    # Compter les routes
    $pageCount = Count-Files -Path (Join-Path $storefrontPath "app") -Pattern "page.tsx"
    Write-Host "     → $pageCount pages" -ForegroundColor Cyan
    
    # Lister les routes API
    Write-Host "     → Routes API:" -ForegroundColor Cyan
    $apiRoutes = Get-ApiRoutes -AppPath $storefrontPath
    
    if ($apiRoutes.Count -eq 0) {
        Write-Host "       ⚠️  Aucune route API trouvée" -ForegroundColor Yellow
    } else {
        foreach ($route in ($apiRoutes | Sort-Object)) {
            Write-Host "       • $route" -ForegroundColor White
        }
    }
}

# Vérifier Admin
Write-Host "`n⚙️  apps/admin" -NoNewline
$adminPath = Join-Path $ProjectRoot "apps\admin"
$adminExists = Test-ModuleExists $adminPath

if ($adminExists) {
    $pageCount = Count-Files -Path (Join-Path $adminPath "app") -Pattern "page.tsx"
    Write-Host "     → $pageCount pages" -ForegroundColor Cyan
    
    # Lister les routes API
    Write-Host "     → Routes API:" -ForegroundColor Cyan
    $apiRoutes = Get-ApiRoutes -AppPath $adminPath
    
    if ($apiRoutes.Count -eq 0) {
        Write-Host "       ⚠️  Aucune route API trouvée" -ForegroundColor Yellow
    } else {
        foreach ($route in ($apiRoutes | Sort-Object)) {
            Write-Host "       • $route" -ForegroundColor White
        }
    }
}

Write-Host "`n`n📊 RÉSUMÉ" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

$totalPackages = $packages.Count
$packageProgress = [math]::Round(($existingPackages / $totalPackages) * 100)

Write-Host "`nPackages: $existingPackages/$totalPackages ($packageProgress%)" -ForegroundColor $(if ($packageProgress -eq 100) { "Green" } elseif ($packageProgress -gt 50) { "Yellow" } else { "Red" })
Write-Host "Storefront: $(if ($storefrontExists) { '✅ Créé' } else { '❌ Manquant' })" -ForegroundColor $(if ($storefrontExists) { "Green" } else { "Red" })
Write-Host "Admin: $(if ($adminExists) { '✅ Créé' } else { '❌ Manquant' })" -ForegroundColor $(if ($adminExists) { "Green" } else { "Red" })

Write-Host "`n" -NoNewline

# Routes critiques à vérifier
Write-Host "`n🎯 ROUTES CRITIQUES STRIPE" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

$criticalRoutes = @(
    @{Path="apps\storefront\app\api\checkout\create-session\route.ts"; Description="Création session Stripe"},
    @{Path="apps\storefront\app\api\webhooks\stripe\route.ts"; Description="Webhook Stripe (paiements)"},
    @{Path="apps\storefront\app\api\orders\by-session\[sessionId]\route.ts"; Description="Récupération commande"},
    @{Path="apps\storefront\app\api\admin\product-images\[imageId]\signed-url\route.ts"; Description="Signed URLs images"}
)

foreach ($route in $criticalRoutes) {
    $fullPath = Join-Path $ProjectRoot $route.Path
    Write-Host "`n$(if (Test-Path $fullPath) { '✅' } else { '❌' }) " -NoNewline -ForegroundColor $(if (Test-Path $fullPath) { "Green" } else { "Red" })
    Write-Host "$($route.Description)" -NoNewline
    Write-Host "`n   $($route.Path)" -ForegroundColor Gray
}

Write-Host "`n`n✨ Analyse terminée!`n" -ForegroundColor Cyan
