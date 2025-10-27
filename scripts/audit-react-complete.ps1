# audit-react-complete.ps1
# Audit complet des versions React (dependencies, devDependencies, peerDependencies)
# Date: 27 octobre 2025

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ⚛️  AUDIT COMPLET REACT - Blanche Renaudin Monorepo" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "❌ Erreur: Monorepo introuvable" -ForegroundColor Red
    exit 1
}

# Statistiques
$stats = @{
    react19 = 0
    react18 = 0
    reactBoth = 0
    noReact = 0
    total = 0
}

$results = @()
$issuesFound = @()

# Fonction pour analyser un package.json
function Analyze-Package {
    param($path, $type)
    
    $packageJson = Join-Path $path "package.json"
    if (-Not (Test-Path $packageJson)) { return }
    
    $content = Get-Content $packageJson -Raw | ConvertFrom-Json
    $name = $content.name
    $relativePath = $path.Replace("$MONOREPO_PATH\", "")
    
    # Récupérer toutes les versions de React
    $deps = @{}
    
    if ($content.dependencies -and $content.dependencies.react) {
        $deps['dependencies'] = $content.dependencies.react
    }
    if ($content.devDependencies -and $content.devDependencies.react) {
        $deps['devDependencies'] = $content.devDependencies.react
    }
    if ($content.peerDependencies -and $content.peerDependencies.react) {
        $deps['peerDependencies'] = $content.peerDependencies.react
    }
    
    $reactDom = $null
    if ($content.dependencies -and $content.dependencies.'react-dom') {
        $reactDom = $content.dependencies.'react-dom'
    }
    if ($content.devDependencies -and $content.devDependencies.'react-dom') {
        $reactDom = $content.devDependencies.'react-dom'
    }
    if ($content.peerDependencies -and $content.peerDependencies.'react-dom') {
        $reactDom = $content.peerDependencies.'react-dom'
    }
    
    $script:stats.total++
    
    if ($deps.Count -eq 0) {
        Write-Host "$($relativePath.PadRight(45)) ⚪ Pas de React (normal)" -ForegroundColor Gray
        $script:stats.noReact++
        return
    }
    
    # Analyser les versions
    $has19 = $false
    $has18 = $false
    $hasOther = $false
    
    foreach ($dep in $deps.GetEnumerator()) {
        $version = $dep.Value
        
        if ($version -match '19') {
            $has19 = $true
        } elseif ($version -match '18') {
            $has18 = $true
        } else {
            $hasOther = $true
        }
    }
    
    # Déterminer le statut
    $status = ""
    $color = "White"
    $issue = $null
    
    if ($has19 -and $has18) {
        $status = "✅ Compatible 18+19"
        $color = "Green"
        $script:stats.reactBoth++
    } elseif ($has19 -and -not $has18) {
        $status = "✅ React 19"
        $color = "Green"
        $script:stats.react19++
    } elseif ($has18 -and -not $has19) {
        $status = "⚠️  React 18 uniquement"
        $color = "Yellow"
        $script:stats.react18++
        
        $issue = [PSCustomObject]@{
            Package = $name
            Path = $relativePath
            Type = $type
            CurrentVersion = ($deps.Values | Select-Object -First 1)
            Action = "À migrer vers React 19"
        }
        $script:issuesFound += $issue
    } else {
        $status = "❓ Version inconnue"
        $color = "Red"
        $hasOther = $true
    }
    
    # Afficher les détails
    Write-Host "$($relativePath.PadRight(45)) $status" -ForegroundColor $color
    
    foreach ($dep in $deps.GetEnumerator()) {
        Write-Host "   $($dep.Key.PadRight(20)) : $($dep.Value)" -ForegroundColor Gray
    }
    
    if ($reactDom -and $reactDom -ne ($deps.Values | Select-Object -First 1)) {
        Write-Host "   ⚠️  react-dom: $reactDom (différent!)" -ForegroundColor Yellow
        
        if (-not $issue) {
            $issue = [PSCustomObject]@{
                Package = $name
                Path = $relativePath
                Type = $type
                CurrentVersion = "Mismatch react/react-dom"
                Action = "Synchroniser les versions"
            }
            $script:issuesFound += $issue
        }
    }
    
    $script:results += [PSCustomObject]@{
        Type = $type
        Name = $name
        Path = $relativePath
        Dependencies = ($deps.Keys -join ', ')
        Versions = ($deps.Values -join ' | ')
        ReactDOM = $reactDom
        Status = $status
    }
    
    Write-Host ""
}

# Analyser les apps
Write-Host "📦 APPLICATIONS:" -ForegroundColor Cyan
Write-Host ""
Get-ChildItem "$MONOREPO_PATH\apps" -Directory | ForEach-Object {
    Analyze-Package $_.FullName "App"
}

# Analyser les packages
Write-Host "📦 PACKAGES:" -ForegroundColor Cyan
Write-Host ""
Get-ChildItem "$MONOREPO_PATH\packages" -Directory | ForEach-Object {
    Analyze-Package $_.FullName "Package"
}

# Statistiques finales
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 STATISTIQUES GLOBALES" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "   React 19 uniquement:       $($stats.react19)" -ForegroundColor Green
Write-Host "   React 18 uniquement:       $($stats.react18)" -ForegroundColor Yellow
Write-Host "   Compatible 18+19:          $($stats.reactBoth)" -ForegroundColor Green
Write-Host "   Sans React:                $($stats.noReact)" -ForegroundColor Gray
Write-Host "   ─────────────────────────────────────────" -ForegroundColor Gray
Write-Host "   TOTAL packages analysés:   $($stats.total)" -ForegroundColor White
Write-Host ""

# Résumé de compatibilité
$compatible = $stats.react19 + $stats.reactBoth
$needsUpgrade = $stats.react18

if ($needsUpgrade -eq 0) {
    Write-Host "✅ EXCELLENT! Tous les packages sont compatibles React 19!" -ForegroundColor Green
} else {
    Write-Host "⚠️  $needsUpgrade package(s) à migrer vers React 19" -ForegroundColor Yellow
}

Write-Host ""

# Liste des problèmes trouvés
if ($issuesFound.Count -gt 0) {
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "🔧 ACTIONS REQUISES" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $issuesFound | ForEach-Object {
        Write-Host "📦 $($_.Package)" -ForegroundColor Yellow
        Write-Host "   Chemin:  $($_.Path)" -ForegroundColor Gray
        Write-Host "   Actuel:  $($_.CurrentVersion)" -ForegroundColor Gray
        Write-Host "   Action:  $($_.Action)" -ForegroundColor White
        Write-Host ""
    }
    
    Write-Host "🚀 COMMANDES DE MIGRATION:" -ForegroundColor Cyan
    Write-Host ""
    
    # Grouper par type d'action
    $toPeerDeps = $issuesFound | Where-Object { $_.Path -like "*packages\ui*" }
    $toUpgrade = $issuesFound | Where-Object { $_.Path -notlike "*packages\ui*" }
    
    if ($toPeerDeps) {
        Write-Host "# 1. Mettre à jour peerDependencies (@repo/ui)" -ForegroundColor Yellow
        Write-Host "   Modifier packages\ui\package.json:" -ForegroundColor Gray
        Write-Host '   "peerDependencies": {' -ForegroundColor Gray
        Write-Host '     "react": "^18.0.0 || ^19.0.0",' -ForegroundColor Gray
        Write-Host '     "react-dom": "^18.0.0 || ^19.0.0"' -ForegroundColor Gray
        Write-Host '   }' -ForegroundColor Gray
        Write-Host ""
    }
    
    if ($toUpgrade) {
        Write-Host "# 2. Migrer les applications vers React 19" -ForegroundColor Yellow
        $toUpgrade | ForEach-Object {
            Write-Host "   pnpm --filter $($_.Package) add react@^19.0.0 react-dom@^19.0.0" -ForegroundColor Gray
        }
        Write-Host ""
    }
    
    Write-Host "# 3. Réinstaller les dépendances" -ForegroundColor Yellow
    Write-Host "   pnpm install" -ForegroundColor Gray
    Write-Host ""
}

# Export du rapport
$reportPath = Join-Path $MONOREPO_PATH "REACT-AUDIT-$(Get-Date -Format 'yyyy-MM-dd-HHmmss').md"

$report = @"
# 📊 Audit React - Blanche Renaudin Monorepo

**Date:** $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')

## Statistiques

- **React 19 uniquement:** $($stats.react19)
- **React 18 uniquement:** $($stats.react18)
- **Compatible 18+19:** $($stats.reactBoth)
- **Sans React:** $($stats.noReact)
- **Total analysé:** $($stats.total)

## Détails par package

| Type | Package | Chemin | Status |
|------|---------|--------|--------|
"@

$results | ForEach-Object {
    $report += "| $($_.Type) | $($_.Name) | $($_.Path) | $($_.Status) |`n"
}

if ($issuesFound.Count -gt 0) {
    $report += "`n## Actions requises`n`n"
    $issuesFound | ForEach-Object {
        $report += "- **$($_.Package)**: $($_.Action)`n"
    }
}

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "📄 Rapport exporté: $reportPath" -ForegroundColor Gray
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Pause
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
