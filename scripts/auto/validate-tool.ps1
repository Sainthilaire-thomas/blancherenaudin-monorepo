# scripts/validate-tool.ps1
<#
.SYNOPSIS
    Valide un tool avant commit pour éviter de casser apps/admin

.DESCRIPTION
    Vérifie exports, types, builds et donne des indications précises sur ce qui manque

.PARAMETER ToolName
    Nom du tool à valider (ex: products, orders, customers)

.PARAMETER Fix
    Tente de corriger automatiquement les problèmes courants

.PARAMETER Verbose
    Affiche plus de détails sur les vérifications

.EXAMPLE
    .\scripts\validate-tool.ps1 products
    .\scripts\validate-tool.ps1 products -Fix
    .\scripts\validate-tool.ps1 products -Verbose
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ToolName,
    
    [switch]$Fix,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$MONOREPO_ROOT = Split-Path -Parent $PSScriptRoot
$ToolPath = "$MONOREPO_ROOT\packages\tools\$ToolName"
$AdminPath = "$MONOREPO_ROOT\apps\admin"

# Couleurs
function Write-Step { param([string]$Message) Write-Host "`n🔹 $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "   ✅ $Message" -ForegroundColor Green }
function Write-Warning { param([string]$Message) Write-Host "   ⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "   ❌ $Message" -ForegroundColor Red }
function Write-Info { param([string]$Message) Write-Host "   ℹ️  $Message" -ForegroundColor Gray }
function Write-Fix { param([string]$Message) Write-Host "   🔧 $Message" -ForegroundColor Magenta }

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🔍 VALIDATION TOOL: @repo/tools-$ToolName" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$startTime = Get-Date
$errors = @()
$warnings = @()

# ═══════════════════════════════════════════════════════════
# ÉTAPE 1 : Vérifier que le tool existe
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 1/9 : Vérification existence du tool"

if (-Not (Test-Path $ToolPath)) {
    Write-Error "Tool introuvable : $ToolPath"
    Write-Info "Créez d'abord le tool avec : .\scripts\create-tool.ps1 $ToolName"
    exit 1
}
Write-Success "Tool trouvé : $ToolPath"

# ═══════════════════════════════════════════════════════════
# ÉTAPE 2 : Vérifier package.json
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 2/9 : Vérification package.json"

$packageJsonPath = "$ToolPath\package.json"
if (-Not (Test-Path $packageJsonPath)) {
    $errors += "package.json manquant"
    Write-Error "package.json manquant"
    exit 1
}

$packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json

# Vérifier name
if ($packageJson.name -ne "@repo/tools-$ToolName") {
    $errors += "package.json name incorrect"
    Write-Error "Name doit être '@repo/tools-$ToolName', trouvé '$($packageJson.name)'"
    
    if ($Fix) {
        Write-Fix "Correction du name dans package.json..."
        $packageJson.name = "@repo/tools-$ToolName"
        $packageJson | ConvertTo-Json -Depth 10 | Set-Content $packageJsonPath
        Write-Success "Name corrigé"
    }
} else {
    Write-Success "Name correct : $($packageJson.name)"
}

# Vérifier scripts obligatoires
$requiredScripts = @("build", "dev", "type-check")
foreach ($script in $requiredScripts) {
    if (-Not $packageJson.scripts.$script) {
        $errors += "Script manquant : $script"
        Write-Error "Script manquant : $script"
    } else {
        if ($Verbose) { Write-Success "Script '$script' présent" }
    }
}

# Vérifier exports
if (-Not $packageJson.exports) {
    $errors += "Champ 'exports' manquant"
    Write-Error "Champ 'exports' manquant dans package.json"
} elseif ($packageJson.exports.'.' -notmatch '\.tsx$') {
    $warnings += "Export doit pointer vers .tsx (pas .ts)"
    Write-Warning "Export devrait pointer vers ./src/index.tsx (pas .ts)"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 3 : Vérifier structure des dossiers
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 3/9 : Vérification structure dossiers"

$requiredFolders = @(
    "src",
    "src\components"
)

foreach ($folder in $requiredFolders) {
    if (-Not (Test-Path "$ToolPath\$folder")) {
        $errors += "Dossier manquant : $folder"
        Write-Error "Dossier manquant : $folder"
        
        if ($Fix) {
            Write-Fix "Création du dossier $folder..."
            New-Item -ItemType Directory -Path "$ToolPath\$folder" -Force | Out-Null
            Write-Success "Dossier créé"
        }
    } else {
        if ($Verbose) { Write-Success "Dossier présent : $folder" }
    }
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 4 : Vérifier index.tsx (CRITIQUE)
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 4/9 : Vérification index.tsx (CRITIQUE)"

$indexPath = "$ToolPath\src\index.tsx"
$indexPathTs = "$ToolPath\src\index.ts"

# CRITIQUE : Doit être .tsx pour JSX
if (Test-Path $indexPathTs) {
    $errors += "index.ts trouvé au lieu de index.tsx"
    Write-Error "CRITIQUE : index.ts trouvé, doit être index.tsx pour JSX"
    
    if ($Fix) {
        Write-Fix "Renommage index.ts → index.tsx..."
        Move-Item $indexPathTs $indexPath -Force
        Write-Success "Renommé en index.tsx"
    }
}

if (-Not (Test-Path $indexPath)) {
    $errors += "Fichier src/index.tsx manquant"
    Write-Error "Fichier src/index.tsx manquant"
    Write-Info "Créez src/index.tsx avec les exports de vos routes et composants"
} else {
    $indexContent = Get-Content $indexPath -Raw
    
    # Vérifier qu'il y a au moins un export
    if ($indexContent -notmatch "export") {
        $errors += "Aucun export trouvé dans src/index.tsx"
        Write-Error "Aucun export trouvé dans src/index.tsx"
        Write-Info "Ajoutez : export { MyComponent } from './routes/list'"
    } else {
        # Compter les exports
        $exportCount = ([regex]::Matches($indexContent, "export")).Count
        Write-Success "$exportCount export(s) trouvé(s)"
        
        if ($Verbose) {
            Write-Info "Exports détectés :"
            $indexContent -split "`n" | Where-Object { $_ -match "export" } | ForEach-Object {
                Write-Host "     $_" -ForegroundColor Gray
            }
        }
    }
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 5 : Vérifier les layouts des groupes (CRITIQUE)
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 5/9 : Vérification layouts groupes (CRITIQUE)"

$layoutPath = "$AdminPath\app\(tools)\layout.tsx"
if (Test-Path $layoutPath) {
    $layoutContent = Get-Content $layoutPath -Raw
    
    # Vérifier que le layout retourne bien children
    if ($layoutContent -notmatch "return.*children" -and $layoutContent -notmatch "children.*return") {
        $errors += "Layout (tools) ne retourne pas children"
        Write-Error "CRITIQUE : Layout $layoutPath ne retourne pas children"
        Write-Info "Cela casse TOUS les exports du groupe !"
        Write-Info "Solution : return <>{children}</>"
        
        if ($Fix) {
            Write-Fix "Correction du layout..."
            $fixedLayout = @"
export default function ToolsLayout({ children }: { children: React.ReactNode }) {
  return <>{children}</>
}
"@
            Set-Content -Path $layoutPath -Value $fixedLayout
            Write-Success "Layout corrigé"
        }
    } else {
        Write-Success "Layout (tools) correct"
    }
} else {
    Write-Info "Pas de layout (tools), OK"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 6 : Vérifier intégration dans apps/admin
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 6/9 : Vérification intégration apps/admin"

$adminToolPath = "$AdminPath\app\(tools)\$ToolName"
if (-Not (Test-Path $adminToolPath)) {
    $warnings += "Pas de page wrapper dans apps/admin"
    Write-Warning "Aucune page wrapper trouvée : $adminToolPath"
    Write-Info "Créez : $adminToolPath\page.tsx"
} else {
    Write-Success "Page wrapper trouvée : $adminToolPath"
    
    # Vérifier que le wrapper importe bien le tool
    $pageFiles = Get-ChildItem -Path $adminToolPath -Filter "*.tsx" -Recurse -ErrorAction SilentlyContinue
    $hasImport = $false
    foreach ($file in $pageFiles) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match "@repo/tools-$ToolName") {
            $hasImport = $true
            break
        }
    }
    
    if ($hasImport) {
        Write-Success "Import du tool détecté dans le wrapper"
    } else {
        $warnings += "Wrapper ne semble pas importer le tool"
        Write-Warning "Le wrapper n'importe pas '@repo/tools-$ToolName'"
    }
}

# Vérifier transpilePackages dans next.config.ts
$nextConfigPath = "$AdminPath\next.config.ts"
if (Test-Path $nextConfigPath) {
    $nextConfig = Get-Content $nextConfigPath -Raw
    if ($nextConfig -match "@repo/tools-$ToolName") {
        Write-Success "Tool présent dans transpilePackages"
    } else {
        $errors += "Tool absent de transpilePackages"
        Write-Error "Tool absent de next.config.ts transpilePackages"
        Write-Info "Ajoutez '@repo/tools-$ToolName' à la liste"
    }
} else {
    $errors += "next.config.ts introuvable"
    Write-Error "next.config.ts introuvable"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 7 : Type-check du tool
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 7/9 : Type-check du tool"

Write-Info "Lancement : pnpm --filter @repo/tools-$ToolName type-check"
Push-Location $MONOREPO_ROOT
$typeOutput = pnpm --filter "@repo/tools-$ToolName" type-check 2>&1
Pop-Location

if ($LASTEXITCODE -ne 0) {
    $errors += "Type-check du tool échoué"
    Write-Error "Type-check du tool échoué"
    
    # Compter les erreurs
    $errorCount = ([regex]::Matches($typeOutput, "error TS")).Count
    Write-Info "$errorCount erreur(s) TypeScript détectée(s)"
    
    # Montrer les 5 premières erreurs
    $typeErrors = $typeOutput | Select-String "error TS" | Select-Object -First 5
    if ($typeErrors) {
        Write-Info "Premières erreurs :"
        $typeErrors | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Red
        }
    }
} else {
    Write-Success "Type-check du tool réussi"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 8 : Build du tool
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 8/9 : Build du tool"

Write-Info "Lancement : pnpm --filter @repo/tools-$ToolName build"
Push-Location $MONOREPO_ROOT
$buildOutput = pnpm --filter "@repo/tools-$ToolName" build 2>&1
Pop-Location

if ($LASTEXITCODE -ne 0) {
    $errors += "Build du tool échoué"
    Write-Error "Build du tool échoué"
    
    # Analyser l'erreur
    $errorLines = $buildOutput | Select-String "error" -Context 0,2
    if ($errorLines) {
        Write-Info "Erreurs détectées :"
        $errorLines | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Red
        }
    }
} else {
    Write-Success "Build du tool réussi"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 9 : Type-check apps/admin
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 9/9 : Type-check apps/admin (vérification intégration)"

Write-Info "Lancement : pnpm --filter apps/admin type-check"
Push-Location $MONOREPO_ROOT
$adminTypeOutput = pnpm --filter apps/admin type-check 2>&1
Pop-Location

if ($LASTEXITCODE -ne 0) {
    $errors += "Type-check apps/admin échoué"
    Write-Error "Type-check apps/admin échoué"
    
    # Analyser si l'erreur vient du tool
    $toolErrors = $adminTypeOutput | Select-String "@repo/tools-$ToolName"
    if ($toolErrors) {
        Write-Error "Erreurs liées au tool $ToolName détectées :"
        $toolErrors | Select-Object -First 5 | ForEach-Object {
            Write-Host "     $_" -ForegroundColor Red
        }
        Write-Info "Action requise :"
        Write-Host "     1. Vérifiez les exports dans packages/tools/$ToolName/src/index.tsx" -ForegroundColor Yellow
        Write-Host "     2. Vérifiez les imports dans apps/admin/app/(tools)/$ToolName/" -ForegroundColor Yellow
        Write-Host "     3. Types exportés : export type * from './types'" -ForegroundColor Yellow
    }
} else {
    Write-Success "Type-check apps/admin réussi"
}

# ═══════════════════════════════════════════════════════════
# RÉSUMÉ FINAL
# ═══════════════════════════════════════════════════════════
$duration = (Get-Date) - $startTime

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  📊 RÉSUMÉ DE LA VALIDATION" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n⏱️  Durée : $([math]::Round($duration.TotalSeconds, 1))s" -ForegroundColor Gray

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "`n✅ VALIDATION RÉUSSIE ! " -ForegroundColor Green -NoNewline
    Write-Host "Aucun problème détecté." -ForegroundColor Green
    Write-Host "`n🚀 Le tool @repo/tools-$ToolName est prêt à être commité !" -ForegroundColor Green
    exit 0
}

if ($errors.Count -gt 0) {
    Write-Host "`n❌ VALIDATION ÉCHOUÉE" -ForegroundColor Red
    Write-Host "`n$($errors.Count) erreur(s) bloquante(s) :" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
}

if ($warnings.Count -gt 0) {
    Write-Host "`n⚠️  $($warnings.Count) avertissement(s) :" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
}

Write-Host "`n💡 PROCHAINES ÉTAPES :" -ForegroundColor Cyan
if ($errors.Count -gt 0) {
    Write-Host "   1. Corrigez les erreurs ci-dessus" -ForegroundColor White
    Write-Host "   2. Relancez : .\scripts\validate-tool.ps1 $ToolName" -ForegroundColor White
    if (-Not $Fix) {
        Write-Host "   3. Ou tentez une correction auto : .\scripts\validate-tool.ps1 $ToolName -Fix" -ForegroundColor White
    }
}

Write-Host "`n📚 Guides utiles :" -ForegroundColor Cyan
Write-Host "   - docs/20251103-ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md" -ForegroundColor White
Write-Host "   - Section 'Debugging' pour résoudre les problèmes courants" -ForegroundColor White

Write-Host ""
exit 1
