# scripts/auto/diagnose.ps1
# Diagnostic rapide du monorepo et des tools
# Version: 1.3 - BUG FIX toolName
# Date: 04 novembre 2025

param(
    [switch]$Quick,
    [string]$Tool
)

$ErrorActionPreference = "Continue"

# Remonter de 2 niveaux depuis scripts/auto/
$MONOREPO_ROOT = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Couleurs
function Write-Section { 
    param([string]$Message) 
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan 
}

function Write-Check { param([string]$Message) Write-Host "`n[CHECK] $Message" -ForegroundColor Yellow }
function Write-OK { param([string]$Message) Write-Host "   [OK] $Message" -ForegroundColor Green }
function Write-Warning { param([string]$Message) Write-Host "   [WARN] $Message" -ForegroundColor Yellow }
function Write-Error-Custom { param([string]$Message) Write-Host "   [ERROR] $Message" -ForegroundColor Red }
function Write-Info { param([string]$Message) Write-Host "   [INFO] $Message" -ForegroundColor Gray }

$issues = @()
$warnings = @()

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "  DIAGNOSTIC MONOREPO - Blanche Renaudin" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] Racine monorepo: $MONOREPO_ROOT" -ForegroundColor Gray
Write-Host "[INFO] Architecture: Phase 1 (packages/tools)" -ForegroundColor Gray
Write-Host ""

$startTime = Get-Date

# ===============================================
# 1. Environnement
# ===============================================
Write-Section "1. ENVIRONNEMENT"

Write-Check "Verification Node.js"
try {
    $nodeVersion = node --version
    Write-OK "Node.js : $nodeVersion"
    
    $versionNumber = [version]($nodeVersion -replace 'v', '')
    if ($versionNumber.Major -lt 18) {
        $issues += "Node.js version trop ancienne"
        Write-Error-Custom "Version Node.js inferieure a 18 (requis : 18+)"
    }
} catch {
    $issues += "Node.js non installe"
    Write-Error-Custom "Node.js non installe"
}

Write-Check "Verification pnpm"
try {
    $pnpmVersion = pnpm --version
    Write-OK "pnpm : v$pnpmVersion"
} catch {
    $issues += "pnpm non installe"
    Write-Error-Custom "pnpm non installe"
    Write-Info "Installation : npm install -g pnpm"
}

Write-Check "Verification structure monorepo"
$requiredDirs = @(
    "apps/admin",
    "apps/storefront",
    "packages/tools",
    "packages/ui",
    "packages/database"
)

foreach ($dir in $requiredDirs) {
    $fullPath = Join-Path $MONOREPO_ROOT $dir
    if (Test-Path $fullPath) {
        Write-OK "$dir present"
    } else {
        if ($dir -eq "packages/tools") {
            $issues += "Dossier manquant : $dir (CRITIQUE)"
            Write-Error-Custom "$dir manquant (dossier critique pour Phase 1)"
        } elseif ($dir -eq "apps/storefront") {
            Write-Info "$dir absent (optionnel)"
        } else {
            $issues += "Dossier manquant : $dir"
            Write-Error-Custom "$dir manquant"
        }
    }
}

# ===============================================
# 2. Configuration
# ===============================================
Write-Section "2. CONFIGURATION"

Write-Check "Verification pnpm-workspace.yaml"
$workspacePath = Join-Path $MONOREPO_ROOT "pnpm-workspace.yaml"
if (Test-Path $workspacePath) {
    Write-OK "pnpm-workspace.yaml present"
    $workspaceContent = Get-Content $workspacePath -Raw
    if ($workspaceContent -match "packages/tools") {
        Write-OK "Tools inclus dans workspace"
    } else {
        $issues += "Tools non inclus dans pnpm-workspace.yaml"
        Write-Error-Custom "packages/tools non inclus dans workspace"
    }
} else {
    $issues += "pnpm-workspace.yaml manquant"
    Write-Error-Custom "pnpm-workspace.yaml manquant"
}

Write-Check "Verification admin.config.ts (Phase 1)"
$adminConfigPath = Join-Path $MONOREPO_ROOT "apps/admin/admin.config.ts"
if (Test-Path $adminConfigPath) {
    Write-OK "admin.config.ts present (config Phase 1)"
    $configContent = Get-Content $adminConfigPath -Raw
    if ($configContent -match "ToolDefinition") {
        Write-OK "Type ToolDefinition utilise"
    } else {
        Write-Warning "Type ToolDefinition non trouve"
    }
} else {
    Write-Info "admin.config.ts absent (optionnel Phase 1)"
}

Write-Check "Verification next.config.ts"
$nextConfigPath = Join-Path $MONOREPO_ROOT "apps/admin/next.config.ts"
if (Test-Path $nextConfigPath) {
    Write-OK "next.config.ts present"
    $nextConfigContent = Get-Content $nextConfigPath -Raw
    if ($nextConfigContent -match "transpilePackages") {
        Write-OK "transpilePackages configure"
        $toolsMatches = [regex]::Matches($nextConfigContent, "@repo/tools-(\w+)")
        Write-Info "Tools dans transpilePackages : $($toolsMatches.Count)"
    } else {
        $issues += "transpilePackages manquant dans next.config.ts"
        Write-Error-Custom "transpilePackages non configure"
    }
} else {
    $issues += "next.config.ts manquant"
    Write-Error-Custom "next.config.ts manquant"
}

# ===============================================
# 3. Dependances
# ===============================================
Write-Section "3. DEPENDANCES"

Write-Check "Verification node_modules"
$nodeModulesRoot = Join-Path $MONOREPO_ROOT "node_modules"
$nodeModulesAdmin = Join-Path $MONOREPO_ROOT "apps/admin/node_modules"

if (Test-Path $nodeModulesRoot) {
    Write-OK "node_modules racine present"
} else {
    $issues += "node_modules manquant (executez 'pnpm install')"
    Write-Error-Custom "node_modules manquant"
}

if (Test-Path $nodeModulesAdmin) {
    Write-OK "node_modules admin present"
} else {
    Write-Warning "node_modules admin absent (normal avec pnpm workspace)"
}

# ===============================================
# 4. Tools (Phase 1)
# ===============================================
Write-Section "4. TOOLS (PHASE 1)"

$toolsPath = Join-Path $MONOREPO_ROOT "packages/tools"
if (Test-Path $toolsPath) {
    [System.IO.DirectoryInfo[]]$tools = Get-ChildItem -Path $toolsPath -Directory
    
    if ($tools.Count -eq 0) {
        Write-Info "Aucun tool trouve dans packages/tools/"
    } else {
        Write-Info "Tools trouves : $($tools.Count)"
        
        # Si on veut diagnostiquer un tool specifique
        if ($Tool) {
            # Diagnostiquer un tool specifique
            $tools = $tools | Where-Object { $_.Name -eq $Tool }
            if ($tools.Count -eq 0) {
                Write-Error-Custom "Tool '$Tool' introuvable"
                exit 1
            }
        }
        
        foreach ($tool in $tools) {
            # FIX: Definir toolName AVANT de l'utiliser
            $toolName = $tool.Name
            Write-Check "Tool : $toolName"
            
            # Verifier package.json
            $pkgPath = Join-Path $tool.FullName "package.json"
            if (Test-Path $pkgPath) {
                $pkg = Get-Content $pkgPath -Raw | ConvertFrom-Json
                
                # Verifier name
                $expectedName = "@repo/tools-$toolName"
                if ($pkg.name -eq $expectedName) {
                    Write-OK "package.json name correct"
                } else {
                    $issues += "Tool $toolName : name incorrect"
                    Write-Error-Custom "Name incorrect : $($pkg.name) (attendu: $expectedName)"
                }
                
                # Verifier exports
                if ($pkg.exports) {
                    Write-OK "Exports configure"
                } else {
                    $warnings += "Tool $toolName : exports manquant"
                    Write-Warning "Champ exports manquant"
                }
            } else {
                $issues += "Tool $toolName : package.json manquant"
                Write-Error-Custom "package.json manquant"
            }
            
            # Verifier structure src/
            $srcPath = Join-Path $tool.FullName "src"
            if (Test-Path $srcPath) {
                Write-OK "Dossier src/ present"
                
                # Verifier routes/
                $routesPath = Join-Path $srcPath "routes"
                if (Test-Path $routesPath) {
                    $routeFiles = Get-ChildItem -Path $routesPath -Filter "*.tsx"
                    Write-Info "$($routeFiles.Count) route(s) trouvee(s)"
                }
            } else {
                $issues += "Tool $toolName : src/ manquant"
                Write-Error-Custom "Dossier src/ manquant"
            }
            
            # Verifier wrapper admin
            $adminWrapper = Join-Path $MONOREPO_ROOT "apps/admin/app/(tools)/$toolName/page.tsx"
            if (Test-Path $adminWrapper) {
                Write-OK "Wrapper admin present"
            } else {
                $warnings += "Tool $toolName : wrapper admin manquant"
                Write-Warning "Wrapper admin manquant dans apps/admin/app/(tools)/$toolName/"
            }
            
            # Verifier transpilePackages
            if ($nextConfigContent -match "@repo/tools-$toolName") {
                Write-OK "Dans transpilePackages"
            } else {
                $issues += "Tool $toolName : absent de transpilePackages"
                Write-Error-Custom "Absent de transpilePackages"
            }
        }
    }
} else {
    $issues += "Dossier packages/tools manquant"
    Write-Error-Custom "packages/tools manquant"
}

# ===============================================
# 5. Layout & Groupes
# ===============================================
Write-Section "5. LAYOUT GROUPES"

Write-Check "Verification layout (tools)"
$layoutPath = Join-Path $MONOREPO_ROOT "apps/admin/app/(tools)/layout.tsx"
if (Test-Path $layoutPath) {
    Write-OK "Layout (tools) present"
    $layoutContent = Get-Content $layoutPath -Raw
    if ($layoutContent -match "children") {
        Write-OK "Layout retourne children"
    } else {
        $warnings += "Layout ne retourne pas children"
        Write-Warning "Layout doit retourner {children}"
    }
} else {
    $issues += "Layout (tools) manquant"
    Write-Error-Custom "apps/admin/app/(tools)/layout.tsx manquant"
}

# ===============================================
# 6. Build & Type-check (skip en Quick mode)
# ===============================================
if (-not $Quick) {
    Write-Section "6. BUILD ET TYPE-CHECK"
    
    Write-Check "Build Next.js (apps/admin)"
    Push-Location (Join-Path $MONOREPO_ROOT "apps/admin")
    try {
        $buildOutput = pnpm build 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-OK "Build reussi"
        } else {
            $issues += "Build echoue"
            Write-Error-Custom "Build a echoue"
            Write-Info "Sortie : $buildOutput"
        }
    } catch {
        $issues += "Erreur durant le build"
        Write-Error-Custom "Erreur durant le build"
    }
    Pop-Location
    
    Write-Check "Type-check (apps/admin)"
    Push-Location (Join-Path $MONOREPO_ROOT "apps/admin")
    try {
        $typeCheckOutput = pnpm type-check 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-OK "Type-check reussi"
        } else {
            $warnings += "Type-check a des erreurs"
            Write-Warning "Type-check a rencontre des erreurs"
            Write-Info "Sortie : $typeCheckOutput"
        }
    } catch {
        $warnings += "Erreur durant type-check"
        Write-Warning "Erreur durant type-check"
    }
    Pop-Location
} else {
    Write-Info "Mode Quick : build et type-check ignores"
}

# ===============================================
# 7. Cache et problemes courants
# ===============================================
Write-Section "7. CACHE ET PROBLEMES COURANTS"

Write-Check "Verification cache Next.js"
$nextCachePath = Join-Path $MONOREPO_ROOT "apps/admin/.next"
if (Test-Path $nextCachePath) {
    $cacheSize = (Get-ChildItem $nextCachePath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-OK "Cache Next.js present ($([math]::Round($cacheSize, 1)) MB)"
    
    if ($cacheSize -gt 500) {
        $warnings += "Cache Next.js volumineux (>500MB)"
        Write-Warning "Cache volumineux, envisagez de nettoyer"
        Write-Info "Commande : Remove-Item -Recurse -Force apps/admin/.next"
    }
} else {
    Write-Info "Pas de cache Next.js (normal pour nouveau projet)"
}

# ===============================================
# RESUME
# ===============================================
Write-Section "RESUME DU DIAGNOSTIC"

$duration = (Get-Date) - $startTime
Write-Host "`nDuree : $([math]::Round($duration.TotalSeconds, 1))s`n" -ForegroundColor Gray

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "[OK] Aucun probleme detecte !" -ForegroundColor Green
} else {
    if ($issues.Count -gt 0) {
        Write-Host "`n[ERROR] $($issues.Count) erreur(s)`n" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "   - $issue" -ForegroundColor Red
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "`n[WARN] $($warnings.Count) avertissement(s)`n" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "   - $warning" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nACTIONS RECOMMANDEES :`n" -ForegroundColor Cyan
    
    if ($issues -match "node_modules") {
        Write-Host "   1. Reinstaller dependances : pnpm install" -ForegroundColor White
    }
    
    if ($issues -match "transpilePackages") {
        Write-Host "   2. Ajouter tools manquants dans next.config.ts" -ForegroundColor White
    }
    
    if ($warnings -match "wrapper admin") {
        Write-Host "   3. Creer wrappers admin : .\scripts\auto\create-tool.ps1 -ToolName xxx" -ForegroundColor White
    }
    
    if ($warnings -match "Cache") {
        Write-Host "   1. Nettoyer le cache : Remove-Item -Recurse -Force apps/admin/.next" -ForegroundColor White
    }
}

Write-Host "`nDOCUMENTATION UTILE :" -ForegroundColor Cyan
Write-Host "   - docs/06-AUTO/DEMARRAGE-RAPIDE.md" -ForegroundColor White
Write-Host "   - docs/06-AUTO/QUELLE-METHODE-CHOISIR.md" -ForegroundColor White
Write-Host "   - Architecture Phase 1 : packages/tools/ + imports directs" -ForegroundColor White
Write-Host ""

