# Script PowerShell - Génération de rapport de migration
# Usage: .\generate-migration-report.ps1 -ProjectRoot "C:\path\to\project" -OutputFile "rapport.md"

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = ".",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "MIGRATION-REPORT-$(Get-Date -Format 'yyyy-MM-dd').md"
)

$ErrorActionPreference = "Stop"

Write-Host "`n📝 GÉNÉRATION DU RAPPORT DE MIGRATION" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Gray

# Vérifier que le projet existe
if (-not (Test-Path $ProjectRoot)) {
    Write-Host "❌ Projet introuvable: $ProjectRoot" -ForegroundColor Red
    exit 1
}

# Initialiser le contenu du rapport
$report = @"
# 📊 Rapport de Migration Monorepo - Blanche Renaudin

**Date:** $(Get-Date -Format 'dd MMMM yyyy à HH:mm')  
**Projet:** $ProjectRoot

---

"@

# Fonction pour vérifier l'existence d'un module
function Test-ModuleWithDetails {
    param([string]$Path)
    
    $fullPath = Join-Path $ProjectRoot $Path
    if (Test-Path $fullPath) {
        $files = Get-ChildItem -Path $fullPath -Recurse -File -ErrorAction SilentlyContinue
        return @{
            Exists = $true
            FileCount = $files.Count
            Size = ($files | Measure-Object -Property Length -Sum).Sum
        }
    }
    return @{Exists = $false; FileCount = 0; Size = 0}
}

# Fonction pour compter les lignes de code
function Get-LinesOfCode {
    param([string]$Path, [string]$Extension = "*.ts*")
    
    $fullPath = Join-Path $ProjectRoot $Path
    if (-not (Test-Path $fullPath)) { return 0 }
    
    $files = Get-ChildItem -Path $fullPath -Filter $Extension -Recurse -File -ErrorAction SilentlyContinue
    $totalLines = 0
    
    foreach ($file in $files) {
        $totalLines += (Get-Content $file.FullName -ErrorAction SilentlyContinue).Count
    }
    
    return $totalLines
}

# Section: Vue d'ensemble
Write-Host "`n📊 Collecte des données - Vue d'ensemble..." -ForegroundColor Yellow

$report += @"
## 🎯 Vue d'ensemble

"@

# Calculer le score global
$totalScore = 0
$maxScore = 0

# Packages
$packages = @(
    "config", "database", "ui", "utils", "auth", 
    "email", "sanity", "shipping", "analytics", "newsletter"
)

$packagesExist = 0
foreach ($pkg in $packages) {
    $info = Test-ModuleWithDetails -Path "packages\$pkg"
    if ($info.Exists) { $packagesExist++ }
    $maxScore++
}

$totalScore += $packagesExist

$report += "**Packages:** $packagesExist / $($packages.Count) ✅`n"
$report += "**Applications:** "

# Applications
$storefrontInfo = Test-ModuleWithDetails -Path "apps\storefront"
$adminInfo = Test-ModuleWithDetails -Path "apps\admin"

$appsCount = 0
if ($storefrontInfo.Exists) { $appsCount++; $totalScore++ }
if ($adminInfo.Exists) { $appsCount++; $totalScore++ }
$maxScore += 2

$report += "$appsCount / 2 "
if ($storefrontInfo.Exists) { $report += "✅ " } else { $report += "❌ " }
if ($adminInfo.Exists) { $report += "✅`n" } else { $report += "❌`n" }

# Routes API Stripe
$stripeRoutes = @(
    "apps\storefront\app\api\webhooks\stripe\route.ts",
    "apps\storefront\app\api\checkout\create-session\route.ts",
    "apps\storefront\app\api\orders\by-session\[sessionId]\route.ts"
)

$stripeRoutesCount = 0
foreach ($route in $stripeRoutes) {
    $fullPath = Join-Path $ProjectRoot $route
    if (Test-Path $fullPath) { $stripeRoutesCount++; $totalScore++ }
    $maxScore++
}

$report += "**Routes Stripe:** $stripeRoutesCount / $($stripeRoutes.Count) "
$report += if ($stripeRoutesCount -eq $stripeRoutes.Count) { "✅`n" } else { "⚠️`n" }

# Calcul du pourcentage global
$globalProgress = [math]::Round(($totalScore / $maxScore) * 100)

$report += @"

### 📈 Progression globale

``````
$('█' * [math]::Floor($globalProgress / 5))$('░' * (20 - [math]::Floor($globalProgress / 5))) $globalProgress%
``````

"@

# État par couleur
$status = if ($globalProgress -eq 100) { "🟢 COMPLET" } 
          elseif ($globalProgress -ge 70) { "🟡 AVANCÉ" }
          elseif ($globalProgress -ge 40) { "🟠 EN COURS" }
          else { "🔴 DÉBUT" }

$report += "**Statut:** $status`n`n"

$report += "---`n`n"

# Section: Packages détaillés
Write-Host "📦 Collecte des données - Packages..." -ForegroundColor Yellow

$report += @"
## 📦 Packages

| Package | Statut | Fichiers | Lignes de code | Taille |
|---------|--------|----------|----------------|--------|
"@

foreach ($pkg in $packages) {
    $info = Test-ModuleWithDetails -Path "packages\$pkg"
    $status = if ($info.Exists) { "✅" } else { "❌" }
    $loc = if ($info.Exists) { Get-LinesOfCode -Path "packages\$pkg" } else { 0 }
    $sizeMB = if ($info.Size -gt 0) { [math]::Round($info.Size / 1MB, 2) } else { 0 }
    
    $report += "`n| @repo/$pkg | $status | $($info.FileCount) | $loc | $sizeMB MB |"
}

$report += "`n`n---`n`n"

# Section: Applications
Write-Host "🏪 Collecte des données - Applications..." -ForegroundColor Yellow

$report += @"
## 🏪 Applications

### Storefront

"@

if ($storefrontInfo.Exists) {
    $pageCount = (Get-ChildItem -Path (Join-Path $ProjectRoot "apps\storefront\app") -Filter "page.tsx" -Recurse -File -ErrorAction SilentlyContinue).Count
    $apiRouteCount = (Get-ChildItem -Path (Join-Path $ProjectRoot "apps\storefront\app\api") -Filter "route.ts*" -Recurse -File -ErrorAction SilentlyContinue).Count
    $componentCount = (Get-ChildItem -Path (Join-Path $ProjectRoot "apps\storefront\components") -Filter "*.tsx" -Recurse -File -ErrorAction SilentlyContinue).Count
    $loc = Get-LinesOfCode -Path "apps\storefront"
    
    $report += @"
- ✅ **Statut:** Créé
- 📄 **Pages:** $pageCount
- 🔌 **Routes API:** $apiRouteCount
- 🧩 **Composants:** $componentCount
- 📏 **Lignes de code:** $loc

"@
} else {
    $report += "- ❌ **Statut:** Non créé`n`n"
}

$report += @"
### Admin

"@

if ($adminInfo.Exists) {
    $pageCount = (Get-ChildItem -Path (Join-Path $ProjectRoot "apps\admin\app") -Filter "page.tsx" -Recurse -File -ErrorAction SilentlyContinue).Count
    $loc = Get-LinesOfCode -Path "apps\admin"
    
    $report += @"
- ✅ **Statut:** Créé
- 📄 **Pages:** $pageCount
- 📏 **Lignes de code:** $loc

"@
} else {
    $report += "- ❌ **Statut:** Non créé`n`n"
}

$report += "---`n`n"

# Section: Routes Stripe
Write-Host "💳 Collecte des données - Routes Stripe..." -ForegroundColor Yellow

$report += @"
## 💳 Routes Stripe

| Route | Statut | Lignes | Fonctions |
|-------|--------|--------|-----------|
"@

$routeDetails = @(
    @{
        Name = "Webhook Stripe"
        Path = "apps\storefront\app\api\webhooks\stripe\route.ts"
        Functions = @("handleCheckoutSessionCompleted", "handlePaymentIntentSucceeded", "createOrderItemsFromSession", "parseAddress")
    },
    @{
        Name = "Create Session"
        Path = "apps\storefront\app\api\checkout\create-session\route.ts"
        Functions = @()
    },
    @{
        Name = "Get Order"
        Path = "apps\storefront\app\api\orders\by-session\[sessionId]\route.ts"
        Functions = @()
    }
)

foreach ($route in $routeDetails) {
    $fullPath = Join-Path $ProjectRoot $route.Path
    
    if (Test-Path $fullPath) {
        $lines = (Get-Content $fullPath -ErrorAction SilentlyContinue).Count
        $content = Get-Content $fullPath -Raw -ErrorAction SilentlyContinue
        
        $functionsFound = 0
        foreach ($func in $route.Functions) {
            if ($content -match $func) { $functionsFound++ }
        }
        
        $funcDisplay = if ($route.Functions.Count -gt 0) { "$functionsFound / $($route.Functions.Count)" } else { "-" }
        
        $report += "`n| $($route.Name) | ✅ | $lines | $funcDisplay |"
    } else {
        $report += "`n| $($route.Name) | ❌ | - | - |"
    }
}

$report += "`n`n---`n`n"

# Section: Prochaines étapes
Write-Host "📝 Génération des recommandations..." -ForegroundColor Yellow

$report += @"
## 🎯 Prochaines étapes

"@

$nextSteps = @()

# Vérifier ce qui manque
if ($packagesExist -lt $packages.Count) {
    $missingPackages = @()
    foreach ($pkg in $packages) {
        $info = Test-ModuleWithDetails -Path "packages\$pkg"
        if (-not $info.Exists) { $missingPackages += "@repo/$pkg" }
    }
    $nextSteps += "### 🔴 PRIORITÉ HAUTE`n`nCréer les packages manquants:`n" + ($missingPackages | ForEach-Object { "- $_" }) -join "`n"
}

if ($stripeRoutesCount -lt $stripeRoutes.Count) {
    $missingRoutes = @()
    foreach ($route in $stripeRoutes) {
        $fullPath = Join-Path $ProjectRoot $route
        if (-not (Test-Path $fullPath)) { 
            $routeName = Split-Path $route -Leaf
            $missingRoutes += "$routeName"
        }
    }
    $nextSteps += "`n`n### 🟡 IMPORTANT`n`nCompléter les routes Stripe:`n" + ($missingRoutes | ForEach-Object { "- $_" }) -join "`n"
}

if (-not $adminInfo.Exists) {
    $nextSteps += "`n`n### 🟡 IMPORTANT`n`nCréer l'application admin:`n- Initialiser apps/admin`n- Migrer le dashboard`n- Créer les modules de gestion"
}

if ($nextSteps.Count -eq 0) {
    $report += "✅ **Toutes les étapes critiques sont complètes!**`n`n"
    $report += "Prochaines optimisations recommandées:`n"
    $report += "- Tests E2E avec Playwright`n"
    $report += "- Optimisation des performances`n"
    $report += "- Documentation des packages`n"
    $report += "- CI/CD avec GitHub Actions`n"
} else {
    $report += $nextSteps -join "`n"
}

$report += "`n`n---`n`n"

# Section: Métriques
$report += @"
## 📊 Métriques

**Généré le:** $(Get-Date -Format 'dd/MM/yyyy à HH:mm:ss')  
**Durée d'analyse:** N/A  
**Outils:** PowerShell 7+

---

*Rapport généré automatiquement par le script de migration Blanche Renaudin*

"@

# Écrire le fichier
$outputPath = Join-Path $ProjectRoot $OutputFile
Set-Content -Path $outputPath -Value $report -Encoding UTF8

Write-Host "`n✅ Rapport généré avec succès!" -ForegroundColor Green
Write-Host "   📄 Fichier: $outputPath" -ForegroundColor Cyan
Write-Host "   📏 Taille: $([math]::Round((Get-Item $outputPath).Length / 1KB, 2)) KB" -ForegroundColor Cyan

Write-Host "`n💡 Pour visualiser le rapport:" -ForegroundColor Yellow
Write-Host "   - Ouvrir dans VS Code: code `"$outputPath`"" -ForegroundColor Cyan
Write-Host "   - Ou simplement: cat `"$outputPath`"" -ForegroundColor Cyan

Write-Host "`n✨ Terminé!`n" -ForegroundColor Cyan
