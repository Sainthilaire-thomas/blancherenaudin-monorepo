# check-react-versions.ps1
# Script de vérification des versions React - Blanche Renaudin Monorepo
# Date: 27 octobre 2025

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ⚛️  Vérification des versions React" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Configuration
$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

# Vérifier que le monorepo existe
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "❌ Erreur: Monorepo introuvable à $MONOREPO_PATH" -ForegroundColor Red
    Write-Host "   Veuillez modifier la variable `$MONOREPO_PATH dans le script" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Monorepo trouvé: $MONOREPO_PATH" -ForegroundColor Green
Write-Host ""

# Fonction pour extraire la version React d'un package.json
function Get-ReactVersion {
    param(
        [string]$PackageJsonPath
    )
    
    if (Test-Path $PackageJsonPath) {
        try {
            $content = Get-Content $PackageJsonPath -Raw | ConvertFrom-Json
            
            $reactVersion = $null
            $reactDomVersion = $null
            
            # Chercher dans dependencies
            if ($content.dependencies) {
                $reactVersion = $content.dependencies.react
                $reactDomVersion = $content.dependencies.'react-dom'
            }
            
            # Chercher dans devDependencies si pas trouvé
            if ((-not $reactVersion) -and $content.devDependencies) {
                $reactVersion = $content.devDependencies.react
                $reactDomVersion = $content.devDependencies.'react-dom'
            }
            
            return @{
                React = $reactVersion
                ReactDOM = $reactDomVersion
                HasReact = ($reactVersion -ne $null)
            }
        } catch {
            return @{
                React = $null
                ReactDOM = $null
                HasReact = $false
            }
        }
    }
    
    return @{
        React = $null
        ReactDOM = $null
        HasReact = $false
    }
}

# Fonction pour déterminer la version majeure
function Get-MajorVersion {
    param([string]$Version)
    
    if (-not $Version) { return "N/A" }
    
    if ($Version -match '19') {
        return "19"
    } elseif ($Version -match '18') {
        return "18"
    } else {
        return "Autre"
    }
}

# Collecter les résultats
$results = @()

Write-Host "🔍 Analyse en cours..." -ForegroundColor Yellow
Write-Host ""

# 1. Root package.json
$rootPackage = Join-Path $MONOREPO_PATH "package.json"
if (Test-Path $rootPackage) {
    $version = Get-ReactVersion $rootPackage
    if ($version.HasReact) {
        $results += [PSCustomObject]@{
            Location = "Root"
            Path = "/"
            React = $version.React
            ReactDOM = $version.ReactDOM
            MajorVersion = Get-MajorVersion $version.React
        }
    }
}

# 2. Apps
$appsPath = Join-Path $MONOREPO_PATH "apps"
if (Test-Path $appsPath) {
    Get-ChildItem -Path $appsPath -Directory | ForEach-Object {
        $packageJson = Join-Path $_.FullName "package.json"
        if (Test-Path $packageJson) {
            $version = Get-ReactVersion $packageJson
            if ($version.HasReact) {
                $results += [PSCustomObject]@{
                    Location = "App"
                    Path = "apps/$($_.Name)"
                    React = $version.React
                    ReactDOM = $version.ReactDOM
                    MajorVersion = Get-MajorVersion $version.React
                }
            }
        }
    }
}

# 3. Packages
$packagesPath = Join-Path $MONOREPO_PATH "packages"
if (Test-Path $packagesPath) {
    Get-ChildItem -Path $packagesPath -Directory | ForEach-Object {
        $packageJson = Join-Path $_.FullName "package.json"
        if (Test-Path $packageJson) {
            $version = Get-ReactVersion $packageJson
            if ($version.HasReact) {
                $results += [PSCustomObject]@{
                    Location = "Package"
                    Path = "packages/$($_.Name)"
                    React = $version.React
                    ReactDOM = $version.ReactDOM
                    MajorVersion = Get-MajorVersion $version.React
                }
            }
        }
    }
}

# Afficher les résultats
if ($results.Count -eq 0) {
    Write-Host "⚠️  Aucune dépendance React trouvée" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "📊 Résultats de l'analyse:" -ForegroundColor Cyan
    Write-Host ""
    
    # Tableau des résultats
    $results | Format-Table -Property @(
        @{Label="Type"; Expression={$_.Location}; Width=10},
        @{Label="Chemin"; Expression={$_.Path}; Width=35},
        @{Label="React"; Expression={$_.React}; Width=15},
        @{Label="ReactDOM"; Expression={$_.ReactDOM}; Width=15},
        @{Label="Version"; Expression={
            switch ($_.MajorVersion) {
                "19" { $color = "Green"; "React 19 ✅" }
                "18" { $color = "Yellow"; "React 18 ⚠️" }
                default { $color = "Red"; $_.MajorVersion }
            }
        }; Width=12}
    ) -AutoSize
    
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   📈 Statistiques" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    $react19Count = ($results | Where-Object { $_.MajorVersion -eq "19" }).Count
    $react18Count = ($results | Where-Object { $_.MajorVersion -eq "18" }).Count
    $otherCount = ($results | Where-Object { $_.MajorVersion -notin @("18", "19") }).Count
    
    Write-Host "React 19: $react19Count" -ForegroundColor Green
    Write-Host "React 18: $react18Count" -ForegroundColor Yellow
    if ($otherCount -gt 0) {
        Write-Host "Autre:    $otherCount" -ForegroundColor Red
    }
    Write-Host ""
    
    # Analyse
    if ($react19Count -eq $results.Count) {
        Write-Host "✅ Tout est en React 19 - Excellent!" -ForegroundColor Green
    } elseif ($react18Count -eq $results.Count) {
        Write-Host "⚠️  Tout est encore en React 18" -ForegroundColor Yellow
        Write-Host "   💡 Considérez la migration vers React 19" -ForegroundColor White
    } else {
        Write-Host "⚠️  Versions mixtes détectées!" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 Recommandations:" -ForegroundColor Cyan
        Write-Host "   1. Unifier sur une seule version (de préférence React 19)" -ForegroundColor White
        Write-Host "   2. Mettre à jour les packages en React 18:" -ForegroundColor White
        
        $results | Where-Object { $_.MajorVersion -eq "18" } | ForEach-Object {
            Write-Host "      - $($_.Path)" -ForegroundColor Gray
        }
        
        Write-Host ""
        Write-Host "   Commandes de migration:" -ForegroundColor White
        Write-Host "   cd $MONOREPO_PATH" -ForegroundColor Gray
        
        $results | Where-Object { $_.MajorVersion -eq "18" } | ForEach-Object {
            Write-Host "   cd $($_.Path) && pnpm add react@^19.0.0 react-dom@^19.0.0" -ForegroundColor Gray
        }
    }
    
    Write-Host ""
    
    # Détails par version
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "   🔍 Détails par version" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    
    if ($react19Count -gt 0) {
        Write-Host "✅ React 19:" -ForegroundColor Green
        $results | Where-Object { $_.MajorVersion -eq "19" } | ForEach-Object {
            Write-Host "   - $($_.Path)" -ForegroundColor White
        }
        Write-Host ""
    }
    
    if ($react18Count -gt 0) {
        Write-Host "⚠️  React 18:" -ForegroundColor Yellow
        $results | Where-Object { $_.MajorVersion -eq "18" } | ForEach-Object {
            Write-Host "   - $($_.Path)" -ForegroundColor White
        }
        Write-Host ""
    }
    
    if ($otherCount -gt 0) {
        Write-Host "❓ Autre version:" -ForegroundColor Red
        $results | Where-Object { $_.MajorVersion -notin @("18", "19") } | ForEach-Object {
            Write-Host "   - $($_.Path) ($($_.React))" -ForegroundColor White
        }
        Write-Host ""
    }
}

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Export des résultats en CSV (optionnel)
$exportPath = Join-Path $MONOREPO_PATH "react-versions-report.csv"
$results | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8
Write-Host "📄 Rapport exporté: $exportPath" -ForegroundColor Gray
Write-Host ""

# Pause pour lire les messages
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
