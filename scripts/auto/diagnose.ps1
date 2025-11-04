# scripts/auto/diagnose.ps1
# Diagnostic monorepo - Version REWRITE 2.0
# Date: 04 novembre 2025

param(
    [switch]$Quick,
    [string]$Tool
)

$ErrorActionPreference = "Continue"

# Racine du monorepo
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
function Write-Warn { param([string]$Message) Write-Host "   [WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param([string]$Message) Write-Host "   [ERROR] $Message" -ForegroundColor Red }
function Write-Info { param([string]$Message) Write-Host "   [INFO] $Message" -ForegroundColor Gray }

$issues = @()
$warnings = @()

Write-Host "`n===============================================" -ForegroundColor Cyan
Write-Host "  DIAGNOSTIC MONOREPO - Blanche Renaudin" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] Racine: $MONOREPO_ROOT" -ForegroundColor Gray
Write-Host "[INFO] Architecture: Phase 1 (packages/tools)" -ForegroundColor Gray
Write-Host ""

$startTime = Get-Date

# ===============================================
# 1. Environnement
# ===============================================
Write-Section "1. ENVIRONNEMENT"

Write-Check "Node.js"
try {
    $nodeVersion = node --version
    Write-OK "Node.js : $nodeVersion"
    
    $versionNum = [version]($nodeVersion -replace 'v', '')
    if ($versionNum.Major -lt 18) {
        $issues += "Node.js trop ancien (minimum 18)"
        Write-Err "Version inferieure a 18"
    }
} catch {
    $issues += "Node.js non installe"
    Write-Err "Node.js non installe"
}

Write-Check "pnpm"
try {
    $pnpmVersion = pnpm --version
    Write-OK "pnpm : v$pnpmVersion"
} catch {
    $issues += "pnpm non installe"
    Write-Err "pnpm non installe"
    Write-Info "Installer avec: npm install -g pnpm"
}

Write-Check "Structure monorepo"
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
        Write-OK "$dir OK"
    } else {
        if ($dir -eq "packages/tools") {
            $issues += "CRITIQUE: $dir manquant"
            Write-Err "$dir manquant (CRITIQUE)"
        } elseif ($dir -eq "apps/storefront") {
            Write-Info "$dir absent (optionnel)"
        } else {
            $issues += "$dir manquant"
            Write-Err "$dir manquant"
        }
    }
}

# ===============================================
# 2. Configuration
# ===============================================
Write-Section "2. CONFIGURATION"

Write-Check "pnpm-workspace.yaml"
$workspaceFile = Join-Path $MONOREPO_ROOT "pnpm-workspace.yaml"
if (Test-Path $workspaceFile) {
    Write-OK "Fichier present"
    $workspaceText = Get-Content $workspaceFile -Raw
    if ($workspaceText -match "packages/tools") {
        Write-OK "Tools inclus"
    } else {
        $issues += "packages/tools absent du workspace"
        Write-Err "packages/tools non declare"
    }
} else {
    $issues += "pnpm-workspace.yaml manquant"
    Write-Err "Fichier manquant"
}

Write-Check "admin.config.ts"
$adminConfig = Join-Path $MONOREPO_ROOT "apps/admin/admin.config.ts"
if (Test-Path $adminConfig) {
    Write-OK "Fichier present"
    $configText = Get-Content $adminConfig -Raw
    if ($configText -match "ToolDefinition") {
        Write-OK "Type ToolDefinition OK"
    } else {
        Write-Warn "ToolDefinition non trouve"
    }
} else {
    Write-Info "Fichier absent (optionnel Phase 1)"
}

Write-Check "next.config.ts"
$nextConfig = Join-Path $MONOREPO_ROOT "apps/admin/next.config.ts"
if (Test-Path $nextConfig) {
    Write-OK "Fichier present"
    $nextConfigText = Get-Content $nextConfig -Raw
    if ($nextConfigText -match "transpilePackages") {
        Write-OK "transpilePackages configure"
        $matches = [regex]::Matches($nextConfigText, "@repo/tools-(\w+)")
        Write-Info "Tools dans transpilePackages: $($matches.Count)"
    } else {
        $issues += "transpilePackages manquant"
        Write-Err "transpilePackages non configure"
    }
} else {
    $issues += "next.config.ts manquant"
    Write-Err "Fichier manquant"
}

# ===============================================
# 3. Dependances
# ===============================================
Write-Section "3. DEPENDANCES"

Write-Check "node_modules"
$nodeModulesRoot = Join-Path $MONOREPO_ROOT "node_modules"
if (Test-Path $nodeModulesRoot) {
    Write-OK "node_modules racine OK"
} else {
    $issues += "node_modules manquant"
    Write-Err "Executer: pnpm install"
}

# ===============================================
# 4. Tools
# ===============================================
Write-Section "4. TOOLS (PHASE 1)"

$toolsDir = Join-Path $MONOREPO_ROOT "packages/tools"
if (-not (Test-Path $toolsDir)) {
    $issues += "packages/tools manquant"
    Write-Err "Dossier packages/tools introuvable"
} else {
    # Recuperer la liste des dossiers
    $toolDirs = Get-ChildItem -Path $toolsDir -Directory
    
    if ($toolDirs.Count -eq 0) {
        Write-Info "Aucun tool trouve"
    } else {
        Write-Info "Tools detectes: $($toolDirs.Count)"
        
        # Filtrer si tool specifique demande
        if ($Tool) {
            $toolDirs = $toolDirs | Where-Object { $_.Name -eq $Tool }
            if ($toolDirs.Count -eq 0) {
                Write-Err "Tool '$Tool' introuvable"
                exit 1
            }
        }
        
        # Analyser chaque tool
        foreach ($toolDir in $toolDirs) {
            $name = $toolDir.Name
            $path = $toolDir.FullName
            
            Write-Check "Tool: $name"
            
            # package.json
            $pkgFile = Join-Path $path "package.json"
            if (Test-Path $pkgFile) {
                $pkg = Get-Content $pkgFile -Raw | ConvertFrom-Json
                $expectedName = "@repo/tools-$name"
                
                if ($pkg.name -eq $expectedName) {
                    Write-OK "package.json OK"
                } else {
                    $issues += "Tool ${name}: mauvais nom ($($pkg.name))"
                    Write-Err "Nom incorrect: $($pkg.name)"
                }
                
                if ($pkg.exports) {
                    Write-OK "Exports configure"
                } else {
                    $warnings += "Tool ${name}: exports manquant"
                    Write-Warn "Exports manquant"
                }
            } else {
                $issues += "Tool ${name}: package.json manquant"
                Write-Err "package.json manquant"
            }
            
            # Structure src/
            $srcDir = Join-Path $path "src"
            if (Test-Path $srcDir) {
                Write-OK "Dossier src/ OK"
                
                $routesDir = Join-Path $srcDir "routes"
                if (Test-Path $routesDir) {
                    $routes = Get-ChildItem -Path $routesDir -Filter "*.tsx"
                    Write-Info "$($routes.Count) route(s)"
                }
            } else {
                $issues += "Tool ${name}: src/ manquant"
                Write-Err "Dossier src/ manquant"
            }
            
            # Wrapper admin
            $wrapperFile = Join-Path $MONOREPO_ROOT "apps/admin/app/(tools)/$name/page.tsx"
            if (Test-Path $wrapperFile) {
                Write-OK "Wrapper admin OK"
            } else {
                $warnings += "Tool ${name}: wrapper admin manquant"
                Write-Warn "Wrapper manquant dans apps/admin/app/(tools)/$name/"
            }
            
            # transpilePackages
            if ($nextConfigText -match "@repo/tools-$name") {
                Write-OK "Dans transpilePackages"
            } else {
                $issues += "Tool ${name}: absent de transpilePackages"
                Write-Err "Absent de transpilePackages"
            }
        }
    }
}

# ===============================================
# 5. Layout
# ===============================================
Write-Section "5. LAYOUT"

Write-Check "Layout (tools)"
$layoutFile = Join-Path $MONOREPO_ROOT "apps/admin/app/(tools)/layout.tsx"
if (Test-Path $layoutFile) {
    Write-OK "Layout present"
    $layoutText = Get-Content $layoutFile -Raw
    if ($layoutText -match "children") {
        Write-OK "Retourne children"
    } else {
        $warnings += "Layout ne retourne pas children"
        Write-Warn "Doit retourner {children}"
    }
} else {
    $issues += "Layout (tools) manquant"
    Write-Err "apps/admin/app/(tools)/layout.tsx manquant"
}

# ===============================================
# 6. Build (skip en Quick)
# ===============================================
if (-not $Quick) {
    Write-Section "6. BUILD"
    
    Write-Check "Build Next.js"
    Push-Location (Join-Path $MONOREPO_ROOT "apps/admin")
    try {
        $null = pnpm build 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-OK "Build reussi"
        } else {
            $issues += "Build echoue"
            Write-Err "Build a echoue"
        }
    } catch {
        $issues += "Erreur build"
        Write-Err "Erreur durant le build"
    }
    Pop-Location
} else {
    Write-Info "Mode Quick: build ignore"
}

# ===============================================
# 7. Cache
# ===============================================
Write-Section "7. CACHE"

Write-Check "Cache Next.js"
$cacheDir = Join-Path $MONOREPO_ROOT "apps/admin/.next"
if (Test-Path $cacheDir) {
    $cacheSize = (Get-ChildItem $cacheDir -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-OK "Cache present ($([math]::Round($cacheSize, 1)) MB)"
    
    if ($cacheSize -gt 500) {
        $warnings += "Cache volumineux (>500MB)"
        Write-Warn "Cache volumineux, nettoyer recommande"
        Write-Info "Commande: Remove-Item -Recurse -Force apps/admin/.next"
    }
} else {
    Write-Info "Pas de cache"
}

# ===============================================
# RESUME
# ===============================================
Write-Section "RESUME"

$duration = (Get-Date) - $startTime
Write-Host "`nDuree: $([math]::Round($duration.TotalSeconds, 1))s`n" -ForegroundColor Gray

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "[OK] Aucun probleme detecte!" -ForegroundColor Green
} else {
    if ($issues.Count -gt 0) {
        Write-Host "`n[ERROR] $($issues.Count) erreur(s):`n" -ForegroundColor Red
        foreach ($issue in $issues) {
            Write-Host "   - $issue" -ForegroundColor Red
        }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "`n[WARN] $($warnings.Count) avertissement(s):`n" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "   - $warning" -ForegroundColor Yellow
        }
    }
    
    Write-Host "`nACTIONS:`n" -ForegroundColor Cyan
    
    if ($issues -match "node_modules") {
        Write-Host "   1. pnpm install" -ForegroundColor White
    }
    
    if ($issues -match "transpilePackages") {
        Write-Host "   2. Ajouter tools dans next.config.ts" -ForegroundColor White
    }
    
    if ($warnings -match "wrapper") {
        Write-Host "   3. Creer wrappers: .\scripts\auto\create-tool.ps1" -ForegroundColor White
    }
    
    if ($warnings -match "Cache") {
        Write-Host "   4. Nettoyer cache: Remove-Item -Recurse -Force apps/admin/.next" -ForegroundColor White
    }
}

Write-Host "`nDOCS:" -ForegroundColor Cyan
Write-Host "   - docs/06-AUTO/DEMARRAGE-RAPIDE.md" -ForegroundColor White
Write-Host "   - docs/06-AUTO/QUELLE-METHODE-CHOISIR.md" -ForegroundColor White
Write-Host ""
